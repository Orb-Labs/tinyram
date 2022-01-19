{-# LANGUAGE NoImplicitPrelude #-}


module TinyRAM.DecodeInstruction
  ( decodeInstruction
  , bitsPerRegister
  ) where


import TinyRAM.Prelude
import TinyRAM.Types.ImmediateOrRegister (ImmediateOrRegister (..))
import TinyRAM.Types.Instruction (Instruction (..))
import TinyRAM.Types.Opcode (Opcode (..))
import TinyRAM.Types.Register (Register (..))
import TinyRAM.Types.RegisterCount (RegisterCount (..))
import TinyRAM.Types.Word (Word (..))


decodeInstruction :: RegisterCount -> (Word, Word) -> Instruction
decodeInstruction rc i@(i0, _i1) =
  Instruction
  (decodeOpcode i0)
  (decodeA i)
  (decodeRI rc i0)
  (decodeRJ rc i0)


decodeOpcode :: Word -> Opcode
decodeOpcode i0 = Opcode . fromIntegral $ i0 .&. opcodeBitmask


opcodeBitmask :: Word
opcodeBitmask = 31


decodeRI :: RegisterCount -> Word -> Register
decodeRI rc (Word w) = Register . fromIntegral
  $ (w `shift` (-6)) .&. registerBitmask rc


decodeRJ :: RegisterCount -> Word -> Register
decodeRJ rc (Word w) = Register . fromIntegral
  $ (w `shift` negate (6 + bitsPerRegister rc)) .&. registerBitmask rc


bitsPerRegister :: RegisterCount -> Int
bitsPerRegister (RegisterCount rc) = ceiling (logBase 2 (fromIntegral rc) :: Double)


registerBitmask :: RegisterCount -> Integer
registerBitmask rc = 2 ^ (bitsPerRegister rc) - 1


decodeA :: (Word, Word) -> ImmediateOrRegister
decodeA (i0, i1) =
  case i0 .&. flagBitmask of
    0 -> IsRegister . Register . fromIntegral $ i1
    _ -> IsImmediate i1


flagBitmask :: Word
flagBitmask = 32
