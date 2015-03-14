module Te.Util where

import Import

import Data.Text (concat, Text)
import Shelly


findRootDir :: Text -> Sh (Maybe FilePath)
findRootDir fileToFind = do
  startingDir <- pwd
  dir <- go
  cd startingDir
  return dir

  where
    go = do
      filePresent <- hasFile fileToFind
      currentDir <- pwd
      if filePresent
        then return $ Just currentDir
        else recur currentDir
    recur "/" = return Nothing
    recur _ = do
      cd ".."
      findRootDir fileToFind


hasPipe :: Sh Bool
hasPipe = hasFile ".te-pipe"


hasFile :: Text -> Sh Bool
hasFile filename = do
  let relativeFileName = (fromText . concat) ["./", filename]
  files <- ls $ fromText "."
  return $ any (== relativeFileName) files
