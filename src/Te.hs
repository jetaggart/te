module Te (test, asyncAvailable, listen, fail, commands) where

import System.Exit

import Data.Text (pack, unpack, Text, splitOn, strip, intercalate, concat, replicate)

import Shelly

import Import
import Te.Listen as Te (listen)
import Te.Runner


test :: [Text] -> Sh ()
test args = do
  go =<< hasPipe
  where
    go :: Bool -> Sh ()
    go pipePresent = do
      let executable = "rspec"
      case pipePresent of
        True -> asynchronous executable
        False -> synchronous executable

    asynchronous :: Text -> Sh ()
    asynchronous executable = do
      let stringArgs = intercalate " " args
          testCommand = fromText $ concat ["echo \"", executable, " ", stringArgs, "\" > .te-pipe"]

      escaping False $ run_ testCommand []

    synchronous :: Text -> Sh ()
    synchronous executable = runTestCommand executable args


commands :: Sh ()
commands = echo "Valid commands are: run, listen, help" >> quietExit 0


asyncAvailable :: Sh ()
asyncAvailable = go =<< hasPipe
  where go pipe = case pipe of
                    True -> quietExit 0
                    False -> quietExit 1

fail :: Sh ()
fail = do
  echo "I don't know what to do. Please see README for more info."
  echo "Valid commands are: run, listen."
  quietExit 1


