module Te (test, asyncAvailable, listen, fail, commands) where

import System.Exit

import Data.Text (pack, unpack, Text, splitOn, strip, intercalate, concat, replicate)

import Shelly

import Import
import Te.Types
import Te.Listen as Te (listen)
import Te.Runner


test :: [Text] -> Sh ()
test args = do
  go =<< hasPipe
  where
    go :: Bool -> Sh ()
    go pipePresent = do
      testFramework <- getTestFramework args

      case pipePresent of
        True -> asynchronous testFramework
        False -> synchronous testFramework

    asynchronous :: TestFramework -> Sh ()
    asynchronous (TestFramework executable testArgs) = do
      let stringArgs = intercalate " " testArgs
          testCommand = fromText $ concat ["echo \"", executable, " ", stringArgs, "\" > .te-pipe"]

      escaping False $ run_ testCommand []

    synchronous :: TestFramework -> Sh ()
    synchronous testFramework = do
      echo $ (pack . show) testFramework
      runTest testFramework


getTestFramework :: [Text] -> Sh TestFramework
getTestFramework args = do
  filePresent <- hasFile ".rspec"
  echo $ (pack . show) filePresent
  case filePresent of
    True -> return $ TestFramework "rspec" args
    False -> return $ TestFramework "ruby" ("-Itest" : args)


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


