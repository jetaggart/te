{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE ViewPatterns #-}

module Te.Runner (runTest, hasPipe, hasFile, getTestRunner, lastTestRunner) where

import System.Process
import System.Directory (setCurrentDirectory, getCurrentDirectory)
import Data.Text (Text, pack, unpack, replicate, concat, intercalate)
import Data.Text.Read (decimal)
import Data.Maybe
import Control.Monad (mapM)

import Shelly

import Import
import Te.Util
import Te.Types
import qualified Te.History as History


runTest :: TestRunner -> Sh ()
runTest (isNewTestRunner -> Just testRunner)  = do
  History.record testRunner
  runTest' testRunner

runTest (isOldTestRunner -> Just testRunner) = runTest' testRunner

runTest' :: TestRunner -> Sh ()
runTest' (isTestRunner -> Just (exe, rootDir, args)) = do
  let executable = unpack exe
      arguments = fmap unpack args

  startingDir <- liftIO getCurrentDirectory

  liftIO $ setCurrentDirectory . unpack . toTextIgnore $ rootDir
  liftIO $ rawSystem executable arguments
  liftIO $ setCurrentDirectory startingDir

  columns <- silently $ cmd "tput" "cols" :: Sh Text
  let int = case (decimal columns) of
              Right (i, _) -> i
              Left _ -> 5

  echo $ replicate int "-"
  echo ""


getTestRunner :: [Text] -> Sh (Maybe TestRunner)
getTestRunner args = do
  runners <- mapM (getRunner args) frameworks
  let validRunners = catMaybes runners
  return $ case (catMaybes runners) of
             [] -> Nothing
             (r:_) -> Just r


lastTestRunner :: Sh (Maybe TestRunner)
lastTestRunner = History.last


frameworks :: [TestFramework]
frameworks = [RSpec, Minitest]


getRunner :: [Argument] -> TestFramework -> Sh (Maybe TestRunner)
getRunner args RSpec = do
  rootDir <- findRootDir "spec"
  return $ case rootDir of
            Just r -> Just $ NewTestRunner "rspec" r args
            Nothing -> Nothing

getRunner args Minitest = do
  rootDir <- findRootDir "test"
  return $ case rootDir of
             Just r -> Just $ NewTestRunner "rake" r ("test" : args)
             Nothing -> Nothing
