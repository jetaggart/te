module Te.Util where

import Import

import Data.Text (concat, pack, Text)
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


hasPipe :: FilePath -> Sh Bool
hasPipe dir = do
  startingDir <- pwd
  cd dir
  present <- hasFile ".te-pipe"
  cd startingDir
  return present


hasFile :: Text -> Sh Bool
hasFile filename = do
  let relativeFileName = (fromText . concat) ["./", filename]
  files <- ls $ fromText "."
  return $ any (== relativeFileName) files
