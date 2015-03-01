{-# LANGUAGE ExtendedDefaultRules #-}

module Te.Runner (runTest, hasPipe, hasFile, getTestRunner, TestRunner(..)) where

import System.Process
import Data.Text (Text, pack, unpack, replicate, concat)
import Data.Text.Read (decimal)
import Data.Maybe
import Control.Monad (mapM)

import Shelly
import Safe (headDef)

import Import
import Te.Util


runTest :: TestRunner -> Sh ()
runTest (TestRunner executable args)  = do
  let command = unpack executable
  liftIO $ rawSystem command (fmap unpack args)

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

