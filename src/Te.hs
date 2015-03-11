module Te (run, runLast, asyncAvailable, listen, fail, commands) where

import Data.Text (Text, intercalate, concat)

import Shelly hiding (run)

import Import
import Te.Listen as Te (listen)
import Te.Runner


run :: [Text] -> Sh ()
run args = run' =<< getTestRunner args


runLast :: Sh ()
runLast = run' =<< lastTestRunner


run' :: Maybe TestRunner -> Sh ()
run' testRunner = do
  go =<< hasPipe
  where
    go pipePresent = do
      case testRunner of
        Just runner -> case pipePresent of
                          True -> asynchronous runner
                          False -> synchronous runner
        Nothing -> echo "No test runner found" >> quietExit 1


asynchronous :: TestRunner -> Sh ()
asynchronous (NewTestRunner executable testArgs) = do
  let stringArgs = intercalate " " testArgs
      testCommand = fromText $ concat ["echo \"", executable, " ", stringArgs, "\" > .te-pipe"]

  escaping False $ run_ testCommand []
asynchronous


synchronous :: TestRunner -> Sh ()
synchronous = runTest


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
