{-# LANGUAGE ExtendedDefaultRules #-}

module Te.Runner (runTest, hasPipe, hasFile, getTestRunner) where

import System.Process
import Data.Text (Text, pack, unpack, replicate, concat)
import Data.Text.Read (decimal)

import Shelly

import Import
import Te.Types
import Te.Util


runTest :: TestRunner -> Sh ()
runTest (TestRunner executable args)  = do
  let command = unpack executable
  liftIO $ rawSystem command (fmap unpack args)

  columns <- silently $ cmd "tput" "cols" :: Sh Text
  let int = case (decimal columns) of
              Right (i, _) -> i
              Left _ -> 5

  echo $ replicate int "-"
  echo ""


getTestRunner :: [Text] -> Sh TestRunner
getTestRunner args = do
  filePresent <- hasFile ".rspec"
  echo $ (pack . show) filePresent
  case filePresent of
    True -> return $ TestRunner "rspec" args
    False -> return $ TestRunner "ruby" ("-Itest" : args)

