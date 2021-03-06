{-# LANGUAGE ViewPatterns #-}

module Te (run, runLast, asyncAvailable, listen, fail, commands) where

import Data.Text (Text, intercalate, concat)

import Shelly hiding (run)

import Import
import Te.Listen as Te (listen)
import Te.Runner
import Te.Types


run :: [Text] -> Sh ()
run args = run' =<< getTestRunner args


runLast :: Sh ()
runLast = run' =<< lastTestRunner


run' :: Maybe TestRunner -> Sh ()
run' maybeRunner = do
  case maybeRunner of
   Just runner -> go runner
   Nothing -> echo "No test runner found" >> quietExit 1

  where
    go runner = do
      let rootDir = getRoot runner
      pipe <- hasPipe rootDir
      if pipe
      then asynchronous runner
      else synchronous runner



asynchronous :: TestRunner -> Sh ()
asynchronous (isTestRunner -> Just (exe, rootDir, args)) = do
  let stringArgs = intercalate " " args
      pipe = concat [(toTextIgnore rootDir), "/.te-pipe"]
      pipeCommand = fromText $ concat ["echo \"", exe, "|",  (toTextIgnore rootDir), "|", stringArgs, "\" >", pipe]

  escaping False $ run_ pipeCommand []


synchronous :: TestRunner -> Sh ()
synchronous = runTest


commands :: Sh ()
commands = echo "Valid commands are: run, listen, help" >> quietExit 0


asyncAvailable :: Sh ()
asyncAvailable = go =<< hasPipe "."
  where go pipe = case pipe of
                    True -> quietExit 0
                    False -> quietExit 1

fail :: Sh ()
fail = do
  echo "I don't know what to do. Please see README for more info."
  echo "Valid commands are: run, listen."
  quietExit 1
