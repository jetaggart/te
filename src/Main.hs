{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

module Main where

import Prelude hiding (FilePath, split, concat)

import Shelly

import System.Environment
import System.Process
import System.Exit
import Control.Monad
import Control.Exception (SomeException, Exception, AsyncException(UserInterrupt), throw)
import Data.Text (pack, unpack, Text, splitOn, strip, intercalate, concat)


main :: IO ()
main = shelly $ do
  args <- liftIO getArgs

  let teCommand = head args
      testArgs = tail args

  case teCommand of
    "run" -> teRun $ map pack testArgs
    "listen" -> teListen
    otherwise -> teFail


teRun :: [Text] -> Sh ()
teRun testArgs = do 
  go =<< hasPipe
  where
    go :: Bool -> Sh ()
    go pipePresent = case pipePresent of
                       True -> asynchronous
                       False -> synchronous

    asynchronous :: Sh ()
    asynchronous = do
      let stringArgs = intercalate " " testArgs
          testCommand = fromText $ concat ["echo \"rspec ", stringArgs, "\" > .te-pipe"]

      escaping False $ run_ testCommand []

    synchronous :: Sh ()
    synchronous = runTestCommand "rspec" testArgs


hasPipe :: Sh Bool
hasPipe = hasFile ".te-pipe"
  where
    hasFile :: Text -> Sh Bool
    hasFile filename = do 
      files <- ls $ fromText "."
      return $ any (== "./.te-pipe") files 


teListen :: Sh ()
teListen = forever $ do 
  go =<< hasPipe

  where 
    go :: Bool -> Sh ()
    go pipePresent = case pipePresent of
                       True -> listen
                       False -> init >> listen

    listen :: Sh ()
    listen = catch_sh listen' handleException

    listen' = do
      command <- cmd "cat" ".te-pipe" :: Sh Text
      let splitCommand = splitOn " " $ strip command
      runTestCommand (head splitCommand) (tail splitCommand)

    init :: Sh ()
    init = cmd "mkfifo" ".te-pipe"

    handleException :: AsyncException -> Sh a
    handleException UserInterrupt = do
      echo "Goodbye!"
      quietExit 0

    handleException e = throw e

runTestCommand :: Text -> [Text] -> Sh ()
runTestCommand commandText argsText = do 
  let command = unpack commandText
      args = map unpack argsText
  liftIO $ rawSystem command args
  return ()


teFail :: Sh ()
teFail = do
  echo "I don't know what to do. Please see README for more info."
  echo "Valid commands are: run, listen."
  quietExit 1

