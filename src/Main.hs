{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

module Main where

import Prelude hiding (FilePath, split, concat)

import Shelly

import System.Environment
import System.Process
import System.Exit
import Control.Monad
import Data.Text (pack, unpack, Text, splitOn, strip, intercalate, concat)

teRun :: [Text] -> Sh ()
teRun testArgs = do
  let stringArgs = intercalate " " testArgs
      testCommand = fromText $ concat ["echo \"rspec ", stringArgs, "\" > .te-pipe"]

  escaping False $ run_ testCommand []
  return ()

teInit :: Sh ()
teInit = do
  cmd "mkfifo" ".te-pipe"

teListen :: Sh ()
teListen = forever $ do
  pipePresent <- hasFile ".te-pipe"

  case pipePresent of
    True -> go
    False -> teInit >> go

  where 
    hasFile :: Text -> Sh Bool
    hasFile filename = do 
      files <- ls $ fromText "."
      return $ any (== "./.te-pipe") files 

    go :: Sh ()
    go = do
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
    "run" -> teRun $ map pack testArgs
    "listen" -> teListen
    otherwise -> teFail

  return ()
