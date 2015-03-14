module Te.Util where

import Import

import Data.Text (concat, Text)
import Shelly


findRootDir :: Text -> Sh (Maybe Text)
findRootDir _ = return Nothing


hasPipe :: Sh Bool
hasPipe = hasFile ".te-pipe"


hasFile :: Text -> Sh Bool
hasFile filename = do
  let relativeFileName = (fromText . concat) ["./", filename]
  files <- ls $ fromText "."
  return $ any (== relativeFileName) files
