{-# LANGUAGE ExtendedDefaultRules #-}

module Te.Runner (runTest, hasPipe, hasFile, getTestRunner, TestRunner(..)) where

import System.Process
import Data.Text (Text, pack, unpack, replicate, concat, intercalate)
import Data.Text.Read (decimal)
import Data.Maybe
import Control.Monad (mapM)

import Shelly
import Safe (headDef)

import Import
import Te.Util


runTest :: TestRunner -> Sh ()
runTest testRunner@(TestRunner exe args)  = do
  record testRunner

  let executable = unpack exe
      arguments = fmap unpack args
  liftIO $ rawSystem executable arguments

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


frameworks :: [TestFramework]
frameworks = [RSpec, Minitest]


type Executable = Text
type Argument = Text
data TestRunner = TestRunner Executable [Argument] deriving (Show)


data TestFramework = RSpec | Minitest


getRunner :: [Argument] -> TestFramework -> Sh (Maybe TestRunner)
getRunner args RSpec = do
  rspecFile <- hasFile ".rspec"
  return $ case rspecFile of
             True -> Just $ TestRunner "rspec" args
             False -> Nothing

getRunner args Minitest = do
  testFile <- hasFile "test"
  return $ case testFile of
             True -> Just $ TestRunner "rake" ("test" : args)
             False -> Nothing

record :: TestRunner -> Sh ()
record (TestRunner executable args) = do
  let stringArgs = intercalate " " args
      historyCommand = fromText $ concat ["echo \"", executable, " ", stringArgs, "\" >> .te-history"]
  escaping False $ run_ historyCommand []
