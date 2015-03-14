module Te.Types where

import Import
import Data.Text (Text(..))


type Executable = Text
type Argument = Text
data TestRunner = OldTestRunner Executable [Argument]
                | NewTestRunner Executable [Argument]
                deriving (Show)
isTestRunner (OldTestRunner exe args) = Just (exe, args)
isTestRunner (NewTestRunner exe args) = Just (exe, args)
isTestRunner _  = Nothing

isOldTestRunner tr@(OldTestRunner _ _) = Just tr
isNewTestRunner tr@(NewTestRunner _ _) = Just tr

data TestFramework = RSpec | Minitest
