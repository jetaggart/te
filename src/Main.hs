{-# LANGUAGE OverloadedStrings #-}

module Main where

import Shelly

import Data.List
import System.Environment
import System.Process
import Data.Text (pack)

main :: IO ()
main = shelly $ verbosely $ do
  args <- liftIO getArgs
  liftIO $ rawSystem "rspec" args
  return ()
