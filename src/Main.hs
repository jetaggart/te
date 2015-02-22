{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

module Main where

import Prelude hiding (FilePath, split)

import Shelly

import Data.List
import System.Environment
import System.Process
import System.Exit
import Control.Monad
import Data.Text (pack, unpack, Text, splitOn, strip)

teRun :: [String] -> Sh ()
teRun testArgs = do
  let stringArgs = intercalate " " testArgs
      testCommand = (fromText . pack) $ "echo \"rspec " ++ stringArgs ++ "\" > .te-pipe"

  escaping False $ do
    run_ testCommand []

  return ()

teInit :: Sh ()
teInit = do
  cmd "mkfifo" ".te-pipe"

teListen :: Sh ()
teListen = forever $ do
  command <- cmd "cat" ".te-pipe" :: Sh Text
  let splitCommand = (map unpack . splitOn " ") $ strip command
  liftIO $ rawSystem (head splitCommand) (tail splitCommand)
  return ()

teFail :: Sh ()
teFail = do
  echo "I don't know what to do. Please see README for more info."
  echo "Valid commands are: run, listen."
  quietExit 1

main :: IO ()
main = shelly $ do
  args <- liftIO getArgs

  let teCommand = head args
      testArgs = tail args

  case teCommand of
    "run" -> teRun testArgs
    "listen" -> teListen
    otherwise -> teFail

  return ()
