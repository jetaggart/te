{-# LANGUAGE OverloadedStrings #-}

module Main where

import Shelly

import Data.List
import System.Environment
import System.Process
import System.Exit
import Data.Text (pack)


executeTests :: [String] -> IO ()
executeTests testArgs = rawSystem "rspec" testArgs >> return ()

main :: IO ()
main = shelly $ verbosely $ do
  args <- liftIO getArgs
  let teCommand = head args
      testArgs = tail args
  
  case teCommand of
    "run" -> liftIO $ executeTests testArgs
    "init" -> echo "nothing yet"
    otherwise -> echo "bad te argument"

  return ()
