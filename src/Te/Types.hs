module Te.Types where

import Import
import Data.Text (Text(..))


type Executable = Text
type Argument = Text
type RootDir = Text
data TestRunner = OldTestRunner Executable RootDir [Argument]
                | NewTestRunner Executable RootDir [Argument]
                deriving (Show)
isTestRunner (OldTestRunner exe rootDir args) = Just (exe, rootDir, args)
isTestRunner (NewTestRunner exe rootDir args) = Just (exe, rootDir, args)
isTestRunner _  = Nothing

isOldTestRunner tr@(OldTestRunner _ _ _) = Just tr
isNewTestRunner tr@(NewTestRunner _ _ _) = Just tr

data TestFramework = RSpec | Minitest
