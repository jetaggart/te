module Te.Types where

import Data.Text
import Import

type Executable = Text
type Argument = Text
data TestFramework = TestFramework Executable [Argument] deriving Show
