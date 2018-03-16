{-# LANGUAGE PatternGuards #-}
module Main where

import Text.Pandoc
import Text.Pandoc.JSON
import Text.Pandoc.Walk (walk, query)
import Text.Pandoc.Options (ReaderOptions(..))
import System.Environment (getArgs)
import qualified Data.ByteString.Lazy as B
import qualified Data.Text.IO as T
import qualified Data.Map as M
import Data.Monoid ((<>))
import Data.Maybe (maybeToList)
import Options.Applicative
import Control.Monad (when, unless)

fontValue :: (String, [String], [(String, String)]) -> Maybe String
fontValue (id, classes, attrs) = M.lookup "font" $ M.fromList attrs

listFonts :: Pandoc -> [String]
listFonts = summariseFonts . query extractSpanFonts
  where summariseFonts :: [String] -> [String]
        summariseFonts = map formatFont . M.toList . count
        count :: [String] -> M.Map String Int
        count = foldr (flip (M.insertWith (+)) 1) M.empty
        formatFont :: (String, Int) -> String
        formatFont (f, o) = "\"" <> f <> "\", " <> show o <> " occurrences"
        extractSpanFonts :: Inline -> [String]
        extractSpanFonts (Span a _) = maybeToList $ fontValue a
        extractSpanFonts _          = []
  
readDoc :: B.ByteString -> IO (Either PandocError Pandoc)
readDoc = runIO . readDocx def{ readerFontsAsAttributes = True }

toString :: [Inline] -> String
toString = query convertSpaces
  where convertSpaces (Str s) = s
        convertSpaces Space = " "
        convertSpaces SoftBreak = "\n"
        convertSpaces Space = "\n"
        convertSpaces _ = ""

fontMatches :: Attr -> [String] -> Bool
fontMatches attrs fonts = case fontValue attrs of
  Just found -> found `elem` fonts
  Nothing    -> False

blocks :: [String] -> Block -> Block
blocks fonts (Para [Span a i])
  | fontMatches a fonts && notEmpty = CodeBlock a s
  where s = toString i
        notEmpty = s /= "" -- empty code blocks not admitted in RST
blocks _ b = b

inlines :: [String] -> Inline -> Inline
inlines fonts (Span a i)
 | fontMatches a fonts = Code a (toString i)
inlines _ i = i

list = do
  c <- B.getContents
  Right d <- readDoc c
  putStr $ unlines $ listFonts d

asCode [] = pure ()
asCode fonts = do
  c <- B.getContents
  Right d <- readDoc c
  T.putStr $ writeJSON def $ walk (inlines fonts) $ walk (blocks fonts) $ d

data Options = Options {
  listOption :: Bool,
  asCodeOption :: [String]
  }

docFontToStyle :: Options -> IO ()
docFontToStyle (Options userList userAsCode) = do
  when (userList) list
  unless (null userAsCode) (asCode userAsCode)

options :: Parser Options
options = Options
          <$> flag False True (long "list"
                               <> help "list fonts in the document"
                               <> showDefault)
          <*> many (strOption (long "as-code"
                         <> help "font to format as code"
                         <> metavar "\"FONT NAME\""))

main = execParser (info options fullDesc) >>= docFontToStyle
