module Te.Types where

import Data.Text
import Import

type Executable = Text
type Argument = Text
data TestRunner = TestRunner Executable [Argument] deriving Show
