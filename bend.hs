import System.Environment
import System.IO
import Data.List
import Data.Ord
import qualified Data.Map as M
import System.Process
splitOn :: (a -> Bool) -> [a] -> [[a]]
splitOn f [] = [[]]
splitOn f (h:t) = let (rh:rt) = splitOn f t
                      ret = (h:rh):rt in
                  if f h then []:ret else ret

getExpected (sigil:hunk) =
    map tail $ filter (\ (h:_) -> h == ' ' || h == '-') hunk

diffHunk orig hunk =
    do let expected = zip [0..] (getExpected hunk)
           allIndices = map (\(num,line) -> map (\x->x-num) (elemIndices line orig)) expected
           start = head . maximumBy (comparing length) . group . sort . concat $ allIndices
           there = take (length expected) $ drop (start-1) orig
       writeFile "/tmp/there" (unlines there)
       writeFile "/tmp/expected" (unlines $ map snd expected)
       --runCommand "diff  -U 8 -p /tmp/there /tmp/expected" >>= waitForProcess
       runCommand "meld /tmp/there /tmp/expected" >>= waitForProcess

main = do args <- getArgs
          if length args /= 1 then
             putStrLn "I only take one argument, a diff file, with hunks that failed to apply cleanly"
            else
              return ()
          let name = head args
          patch <- fmap lines (readFile name)
          let '-':'-':'-':' ':origName = head patch
          orig <- fmap lines (readFile origName)
          putStrLn $ "patch is " ++ show (length patch) ++ " lines long, orig is " ++ show (length orig)  ++ " lines long"
          let hunks = tail $ splitOn (\ lin -> "@@" `isPrefixOf` lin) patch
          putStrLn $ "and I found " ++ show (length hunks) ++ " hunks"
          mapM_ (diffHunk orig) hunks
