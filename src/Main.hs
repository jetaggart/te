module Main where

import System.Environment
import Control.Monad

import Data.Text (pack)

import Shelly

import Import
import qualified Te as Te


main :: IO ()
main = shelly $ do
  args <- liftIO getArgs

  let teCommand = head args
      testArgs = tail args

  case teCommand of
    "run" -> Te.test $ fmap pack testArgs
    "listen" -> Te.listen
    "async-available" -> Te.asyncAvailable
    "help" -> Te.commands 
    otherwise -> Te.fail
