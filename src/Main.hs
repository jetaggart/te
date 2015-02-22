{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}

module Main where

import Prelude hiding (FilePath)

import Shelly

import Data.List
import System.Environment
import System.Process
import System.Exit
import Control.Monad
import Data.Text (pack)

teRun :: [String] -> Sh ()
teRun testArgs = do 
  let stringArgs = intercalate " " testArgs
      testCommand = (fromText . pack) $ "echo \"rspec " ++ stringArgs ++ "\" > .te-pipe"

  escaping False $ do
    run_ testCommand []

  return ()
 

teInit :: Sh ()
teInit = do
  cmd "mkfifo" ".te-pipe"

teListen :: Sh ()
teListen = escaping False $  forever $ do
  liftIO $ system "cat .te-pipe | sh"
  return ()

main :: IO ()
main = shelly $ verbosely $ do
  args <- liftIO getArgs

  let teCommand = head args
      testArgs = tail args
  
  case teCommand of
    "run" -> teRun testArgs
    "init" -> teInit
    "listen" -> teListen
    otherwise -> echo "bad te argument"

  return ()
