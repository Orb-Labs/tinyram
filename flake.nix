{
  nixConfig.bash-prompt = "[nix-develop-tinyram:] ";
  description = "A vnTinyRAM emulator";
  inputs = {
    # Nixpkgs set to specific URL for haskellNix
    nixpkgs.url = "github:NixOS/nixpkgs/baaf9459d6105c243239289e1e82e3cdd5ac4809";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";

    #CI integration
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";
    sydtest-src = {
        url = "github:NorfairKing/sydtest/314d53ae175b540817a24d4211dab24fe6cb9232";
        flake = false;
      };
    validity-src = {
        url = "github:NorfairKing/validity/f5e5d69b3502cdd9243b412c31ba9619b9e89462";
        flake = false;
      };

    #HaskellNix is implemented using a set nixpkgs.follows; allowing for flake-build
    haskellNix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:input-output-hk/haskell.nix";
    };

    coq-tinyram.url = "github:Orbis-Tertius/coq-tinyram";
  };

  outputs = { self, nixpkgs, flake-utils, sydtest-src, validity-src, haskellNix,  flake-compat, flake-compat-ci, coq-tinyram }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        deferPluginErrors = true;
        overlays = [
          haskellNix.overlay
          (import "${sydtest-src}/nix/overlay.nix")
          (import "${validity-src}/nix/overlay.nix")
          (final: prev: {
            tinyram =
              final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc8107";
                projectFileName = "stack.yaml";
                modules = [{
                  packages = {
                    tinyram = {
                      allComponent.preCheck = ''
                        echo -n ${coq-tinyram.defaultPackage.x86_64-linux}/bin/coq-tinyram >/tmp/coq-tinyram-path
                      '';
                    };
                  };
                }];
                shell.tools = {
                  cabal = { };
                  ghcid = { };
                  hlint = { };
                  haskell-language-server = { };
                  stylish-haskell = { };
                  sydtest-discover = { };
                };
                # Non-Haskell shell tools go here
                shell.buildInputs = with pkgs; [
                  nixpkgs-fmt coq-tinyram
                ];
                shell.shellHook =
                  ''
                  export COQ_TINYRAM_PATH=${coq-tinyram.defaultPackage.x86_64-linux}/bin/coq-tinyram
                  alias coq-tinyram=$COQ_TINYRAM_PATH
                  echo -n $COQ_TINYRAM_PATH >/tmp/coq-tinyram-path
                  manual-ci() (
                    set -e

                    ./ci/lint.sh
                    cabal test
                    nix-build
                    ./ci/examples.sh
                  )
                  '';
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.tinyram.flake { };
      in flake // {
        
        ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
          flake = self;
          systems = [ "x86_64-linux" ];
        };
        defaultPackage = flake.packages."tinyram:exe:tinyram";
      });
}
