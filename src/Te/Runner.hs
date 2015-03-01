module Te.Runner (runTestCommand, hasPipe) where

import System.Process
import Data.Text (Text, unpack)

import Shelly

import Import


runTestCommand :: Text -> [Text] -> Sh ()
runTestCommand commandText argsText = do
  let command = unpack commandText
      args = fmap unpack argsText
  liftIO $ rawSystem command args
  return ()


hasPipe :: Sh Bool
hasPipe = hasFile ".te-pipe"
  where
    hasFile :: Text -> Sh Bool
    hasFile filename = do
      files <- ls $ fromText "."
      return $ any (== "./.te-pipe") files


