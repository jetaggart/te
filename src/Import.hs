module Import
       ( module Import ) where

import Prelude as Import hiding (map, init, last, readFile, concat, replicate, writeFile, fail, head, tail, FilePath)


import Safe as Import (headMay, tailSafe)
