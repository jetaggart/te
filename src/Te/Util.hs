module Te.Util where

import Import

import Data.Text (concat, Text)
import Shelly

hasPipe :: Sh Bool
hasPipe = hasFile ".te-pipe"


hasFile :: Text -> Sh Bool
hasFile filename = do
  let relativeFileName = (fromText . concat) ["./", filename]
  files <- ls $ fromText "."
  return $ any (== relativeFileName) files

