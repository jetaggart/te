{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}


module Main where

import System.Environment
import System.Process
import System.Exit

import Control.Monad
import Control.Exception (SomeException, Exception, AsyncException(UserInterrupt), throw)

import Data.Text (pack, unpack, Text, splitOn, strip, intercalate, concat, replicate)
import Data.Text.Read (decimal)

import Shelly

import Te.Imports


main :: IO ()
main = shelly $ do
  args <- liftIO getArgs

  let teCommand = head args
      testArgs = tail args

  case teCommand of
    "run" -> teRun $ fmap pack testArgs
    "listen" -> teListen
    "async-available" -> teAsyncAvailable
    "help" -> echo "Valid commands are: run, listen, help" >> quietExit 0
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

teAsyncAvailable :: Sh ()
teAsyncAvailable = go =<< hasPipe
  where go pipe = case pipe of
                    True -> quietExit 0
                    False -> quietExit 1


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
    listen = catch_sh listen' catchInterrupt

    listen' = do
      command <- cmd "cat" ".te-pipe" :: Sh Text
      let splitCommand = splitOn " " $ strip command
      runTestCommand (head splitCommand) (tail splitCommand)

      columns <- silently $ cmd "tput" "cols" :: Sh Text
      let int = case (decimal columns) of
                  Right (i, _) -> i
                  Left _ -> 5

      echo $ replicate int "-"
      echo ""

    init :: Sh ()
    init = cmd "mkfifo" ".te-pipe"

    catchInterrupt :: AsyncException -> Sh a
    catchInterrupt UserInterrupt = do
      cleanPipe
      echo "Goodbye!"
      quietExit 0

    catchInterrupt e = throw e

    cleanPipe :: Sh ()
    cleanPipe = cmd "rm" ".te-pipe"


runTestCommand :: Text -> [Text] -> Sh ()
runTestCommand commandText argsText = do
  let command = unpack commandText
      args = fmap unpack argsText
  liftIO $ rawSystem command args
  return ()


teFail :: Sh ()
teFail = do
  echo "I don't know what to do. Please see README for more info."
  echo "Valid commands are: run, listen."
  quietExit 1

