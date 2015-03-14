{-# LANGUAGE ViewPatterns #-}

module Te.Types where

import Import
import Shelly (FilePath)
import Data.Text (Text(..))

type Executable = Text
type Argument = Text
type RootDir = FilePath
data TestRunner = OldTestRunner Executable RootDir [Argument]
                | NewTestRunner Executable RootDir [Argument]
                deriving (Show)
isTestRunner (OldTestRunner exe rootDir args) = Just (exe, rootDir, args)
isTestRunner (NewTestRunner exe rootDir args) = Just (exe, rootDir, args)

isOldTestRunner tr@(OldTestRunner _ _ _) = Just tr
isNewTestRunner tr@(NewTestRunner _ _ _) = Just tr

getRoot (isTestRunner -> Just (_, rootDir, _)) = rootDir

data TestFramework = RSpec | Minitest
