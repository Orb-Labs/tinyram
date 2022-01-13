{-# LANGUAGE NoImplicitPrelude #-}


module TinyRAM.Instructions
  ( andBits
  , orBits
  , xorBits
  , notBits
  ) where


import TinyRAM.MachineState (conditionToFlag, getImmediateOrRegister)
import TinyRAM.Prelude
import TinyRAM.Types.HasMachineState (HasMachineState (..))
import TinyRAM.Types.ImmediateOrRegister (ImmediateOrRegister)
import TinyRAM.Types.Register (Register)


andBits :: ( Monad m, HasMachineState m )
  => Register -> Register -> ImmediateOrRegister -> m ()
andBits ri rj a = do
  a'  <- getImmediateOrRegister a
  rj' <- getRegisterValue rj
  case (a', rj') of
    (Just a'', Just rj'') -> do
      let y = a'' .&. rj''
      setRegisterValue ri y
      setConditionFlag (conditionToFlag (y == 0))
    _ -> return ()


orBits :: ( Monad m, HasMachineState m )
  => Register -> Register -> ImmediateOrRegister -> m ()
orBits ri rj a = do
  a'  <- getImmediateOrRegister a
  rj' <- getRegisterValue rj
  case (a', rj') of
    (Just a'', Just rj'') -> do
      let y = a'' .|. rj''
      setRegisterValue ri y
      setConditionFlag (conditionToFlag (y == 0))
    _ -> return ()


xorBits :: ( Monad m, HasMachineState m )
  => Register -> Register -> ImmediateOrRegister -> m ()
xorBits ri rj a = do
  a'  <- getImmediateOrRegister a
  rj' <- getRegisterValue rj
  case (a', rj') of
    (Just a'', Just rj'') -> do
      let y = a'' `xor` rj''
      setRegisterValue ri y
      setConditionFlag (conditionToFlag (y == 0))
    _ -> return ()


notBits :: ( Monad m, HasMachineState m )
  => Register -> ImmediateOrRegister -> m ()
notBits ri a = do
  a' <- getImmediateOrRegister a
  case a' of
    Just a'' -> do
      let y = complement a''
      setRegisterValue ri y
      setConditionFlag (conditionToFlag (y == 0))
    Nothing -> return ()
