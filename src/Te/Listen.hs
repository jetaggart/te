{-# LANGUAGE ExtendedDefaultRules #-}

module Te.Listen (listen) where

import Data.Text (Text, splitOn, strip)
import Control.Monad hiding (fail)
import Control.Exception (SomeException, Exception, AsyncException(UserInterrupt), throw)

import Import
import Shelly
import Te.Runner


listen :: Sh ()
listen = forever $ do
  go =<< hasPipe
  where
    go pipePresent = case pipePresent of
                       True -> listen'
                       False -> init >> listen'


listen' :: Sh ()
listen' = catch_sh go catchInterrupt
  where
    go = do
      command <- cmd "cat" ".te-pipe" :: Sh Text
      let splitCommand = splitOn " " $ strip command

      case (headMay splitCommand) of
        Just c -> runTest $ TestRunner c (tailSafe splitCommand)
        Nothing -> echo "Something went wrong, there should be a command passed" >> quietExit 1


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

