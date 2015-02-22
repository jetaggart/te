{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

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
      testCommand ="\"rspec " ++ stringArgs ++ "\""
  liftIO $ rawSystem ("echo " ++ testCommand ++ " > .te-pipe") []
  return ()
 

teInit :: Sh ()
teInit = do
  cmd "mkfifo" ".te-pipe"

teListen :: Sh ()
teListen = escaping False $  forever $ do
  run_ "cat .te-pipe | sh" []
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
