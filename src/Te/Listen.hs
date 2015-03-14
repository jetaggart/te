{-# LANGUAGE ExtendedDefaultRules #-}

module Te.Listen (listen) where

import Data.Text (Text, splitOn, strip)
import Control.Monad hiding (fail)
import Control.Exception (SomeException, Exception, AsyncException(UserInterrupt), throw)

import Import
import Shelly
import Te.Runner
import Te.Types


listen :: Sh ()
listen = do
  file <- hasFile ".te-pipe"
  case file of
    True -> echo "Te already listening for this directory" >> quietExit 1
    False -> forever $ go =<< hasPipe

  where
    go pipePresent = case pipePresent of
                       True -> listen'
                       False -> init >> listen'


listen' :: Sh ()
listen' = catch_sh go catchInterrupt
  where
    go = do
      command <- cmd "cat" ".te-pipe" :: Sh Text
      let splitCommand = splitOn "|" $ strip command

      case splitCommand of
        (exe:rootDir:args) -> runTest $ NewTestRunner exe (fromText rootDir) args
        otherwise -> echo "Something went wrong, there should be a command passed" >> quietExit 1


init :: Sh ()
init = cmd "mkfifo" ".te-pipe"


catchInterrupt :: AsyncException -> Sh a
catchInterrupt UserInterrupt = do
  cleanPipe
  echo "Goodbye!"
  quietExit 0
catchInterrupt e = throw e


cleanPipe :: Sh ()
cleanPipe = cmd "rm" ".te-pipe"
