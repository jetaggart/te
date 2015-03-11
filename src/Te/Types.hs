module Te.Types where

import Import
import Data.Text (Text(..))


type Executable = Text
type Argument = Text
data TestRunner = TestRunner Executable [Argument] deriving (Show)

data TestFramework = RSpec | Minitest
