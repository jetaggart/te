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

  let teCommand = headMay args
      testArgs = tailSafe args

  case teCommand of
    Nothing -> Te.fail
    Just "run" -> Te.test $ fmap pack testArgs
    Just "listen" -> Te.listen
    Just "async-available" -> Te.asyncAvailable
    Just "help" -> Te.commands
    otherwise -> Te.fail
