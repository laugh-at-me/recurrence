{-# LANGUAGE DataKinds, NoMonomorphismRestriction, TypeOperators, TypeFamilies, FlexibleContexts #-}

module Main (main) where

import Data.Array.Accelerate as A
import Data.Array.Accelerate.LLVM.Native
import Data.Graph.Inductive.Dot
import Data.Graph.Inductive.PatriciaTree
import NeuralNetwork2
import Data.Singletons
import GHC.TypeLits
import Data.Singletons.TypeLits
import Data.Singletons.Prelude.List
import ValueAndDerivative

main :: IO ()
main =
  let
    ir = [[1, 1, 1, 1, 1]]
    ia = (Prelude.map (A.use . A.fromList (Z:.1:.5)) ir) :: [Acc (Matrix Double)]
    i = Prelude.map (\a -> PCons s1 s5 a PNil) ia
    f = (\(PCons _ _ a PNil) -> A.sum a) :: PList ('(1, 3) ': '[]) (ValueAndDerivative Double) -> Acc (Scalar (ValueAndDerivative Double))
    e = (Prelude.foldr (A.zipWith (A.+)) (fill index0 0)) . (Prelude.map f)
    s1 = sing :: SNat 1
    s5 = sing :: SNat 5
    s6 = sing :: SNat 6
    s3 = sing :: SNat 3
    nn = makeNetwork s5 (SNil) s3 :: SomeNeuralNetwork (ValueAndDerivative Double) 5 3
    --p = forwardParams (lift (1.01 :: Double)) s5 s3 nn
  in
    do
      writeFile "file.dot" $ showDot (fglToDot $ (toFGL nn :: Gr Label Label))
      print $ run $ gradient s5 s3 nn e (Prelude.map NeuralNetwork2.flatten i)


