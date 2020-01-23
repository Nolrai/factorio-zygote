{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}


module Main (main) where

import System.Environment (getArgs)
import Data.ByteString.Base64 (decodeBase64)
import Data.ByteString as BS (uncons)
import Codec.Compression.Zlib as Zlib (decompress)

main :: IO ()
main = do

  [path] <- getArgs
  Just (n, blueprintString) <- BS.uncons <$> readFileBS path
  putStrLn $ "read " <> path <> ":"
  putStrLn $ "version number: " <> show n
  putBSLn (blueprintString :: ByteString)

  compressed <-
    either
      (die . toString)
      (fmap toLazy . evaluateNF)
      (decodeBase64 blueprintString)

  putTextLn "Decoded base 64"

  jasonByteString <- evaluateNF $ decompress compressed
  putTextLn "Inflated with zlib:"
  putTextLn . decodeUtf8 . toStrict $  jasonByteString

  

