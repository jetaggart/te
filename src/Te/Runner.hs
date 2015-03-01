{-# LANGUAGE ExtendedDefaultRules #-}

module Te.Runner (runTest, hasPipe, hasFile) where

import System.Process
import Data.Text (Text, unpack, replicate, concat)
import Data.Text.Read (decimal)

import Shelly

import Import
import Te.Types


runTest :: TestFramework -> Sh ()
runTest (TestFramework executable args)  = do
  let command = unpack executable
  liftIO $ rawSystem command (fmap unpack args)

  columns <- silently $ cmd "tput" "cols" :: Sh Text
  let int = case (decimal columns) of
              Right (i, _) -> i
              Left _ -> 5

  echo $ replicate int "-"
  echo ""


hasPipe :: Sh Bool
hasPipe = hasFile ".te-pipe"


hasFile :: Text -> Sh Bool
hasFile filename = do
  let relativeFileName = (fromText . concat) ["./", filename]
  files <- ls $ fromText "."
  return $ any (== relativeFileName) files


