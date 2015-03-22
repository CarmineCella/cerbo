module Ssah.Aggregate where

import Data.List

import Ssah.Utils


--combine p (left:[]) rights = partition (p left) rights
combine' p (left:lefts) rights =
  ins:right
  where
    (ins, outs) = partition (p left) rights
    right = if (length lefts) > 0 then (combine' p lefts outs) else [outs]

-- does a join
combine p lefts rights =
  (init c, last c)
  where c = combine' p lefts rights

showFailures outs = 
  error msg
  where
    msgLines = ["Application generated combine failure:"] ++ (map show outs)
    msg = unlines msgLines
      
strictly (ins, outs) =
  if (length outs) == 0 then ins else showFailures outs

                                      
 

combineKeys leftKey rightKey lefts rights =
  combine  p lefts rights
  where  p l r = ((leftKey l) == (rightKey r))

{-
-- | As combine, but barfs if there are remaining items
combineStrict p lefts rights =
  strictly $ combine p lefts rights
  -}
strictlyCombineKeys  leftKey rightKey lefts rights =
  strictly $ combineKeys leftKey rightKey lefts rights
  
              
testLefts = [10, 11, 12]
testRights =  [11, 12, 11, 12, 5, 11]
testAgg1 = combine (==)  testLefts testRights
-- ([[],[11,11,11],[12,12]],[5])

testAgg2 = strictly (combine (==) testLefts testRights)

groupByKey keyFunc = groupBy (\x y -> keyFunc x == keyFunc y)

nonzero f = not (0.0 == f)

finding p lst =
  foldl f (Nothing, []) lst
  where
    f (res, acc) el =
      if ( (Nothing == res) && (p el) )
      then (Just el, acc) else (res, acc ++ [el])

testFinding = finding (== 10) [12, 13, 10, 14, 10, 15]
-- => (Just 10,[12,13,14,10,15])

              
collate p  (l:[]) rs =
  [(Just l, hit)] ++ misses
  where
    (hit, miss) = finding (p l) rs
    misses = map (\m -> (Nothing, Just m))  miss

collate p (l:ls) rs =
  [(Just l, hit)] ++ (collate p ls misses)
  where
    (hit, misses) = finding (p l) rs

testCollate1 = collate (\l r -> l == r) [10] [11, 12, 10, 13]
-- => [(Just 10,Just 10),(Nothing,Just 11),(Nothing,Just 12),(Nothing,Just 13)]

testCollate2  = collate (\l r -> l == r) [10, 11] [12, 13, 11]
-- => [(Just 10,Nothing),(Just 11,Just 11),(Nothing,Just 12),(Nothing,Just 13)]
