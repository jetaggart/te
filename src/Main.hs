{-# LANGUAGE OverloadedStrings #-}

module Main where

import Shelly

import Data.List
import System.Environment
import System.Process

main :: IO ()
main = do
  rawSystem "rspec" =<< getArgs
  return ()
