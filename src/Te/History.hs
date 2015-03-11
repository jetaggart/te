{-# LANGUAGE ExtendedDefaultRules #-}

module Te.History (record, lastItem) where

import Import

import Shelly
import Data.Text (strip, intercalate, splitOn, concat, Text(..))
import Te.Types (TestRunner(..))


record :: TestRunner -> Sh ()
record (TestRunner executable args) = do
  let stringArgs = intercalate " " args
      historyCommand = fromText $ concat ["echo \"", executable, " ", stringArgs, "\" >> .te-history"]
  escaping False $ run_ historyCommand []


lastItem :: Sh [Text]
lastItem = do
  lastHistoryItem <- cmd "tail" "-1" ".te-history" :: Sh Text
  return $ splitOn " " $ strip lastHistoryItem
