{-# LANGUAGE DataKinds, NoMonomorphismRestriction, TypeOperators, TypeFamilies, FlexibleContexts, OverloadedStrings #-}

module Main (main) where

import Data.Array.Accelerate as A
import Data.Array.Accelerate.Interpreter as B
import Data.Graph.Inductive.Dot
import Data.Graph.Inductive.PatriciaTree
import NeuralNetwork2
import Data.Singletons
import GHC.TypeLits
import Data.Singletons.TypeLits
import Data.Singletons.Prelude.List
import ValueAndDerivative
import Debug.Trace

import Data.Array.Accelerate.Debug
import System.Metrics
import System.Remote.Monitoring

main :: IO ()
main =
  let
    ir = [1, 1.1.. 1.5]
    or = fmap Prelude.sin ir
    ia = (Prelude.map (A.use . A.fromList (Z:.1:.1) . (: [])) ir) :: [Acc (Matrix (Double))]
    oa = Prelude.map (A.map fromValue . A.use . A.fromList (Z:.1:.1) . (\a -> a : [])) or ::[Acc (Matrix (ValueAndDerivative Double))]
    i = Prelude.map (\a -> pSingleton2 s1 s1 a) ia
    s1 = sing :: SNat 1
    s5 = sing :: SNat 1
    nn2 = makeNetwork s1 (SCons s5 SNil) s1 :: SomeNeuralNetwork Double 1 1
--    nn = makeNetwork s1 (SNil) s1 :: SomeNeuralNetwork (ValueAndDerivative Double) 1 1
    --p = forwardParams (lift (1.01 :: Double)) s1 s1 nn
    p = Prelude.last $ Prelude.take 2 $ gradientDescent 0.05 s1 s1 nn2 (mse oa) (Prelude.map pFlatten i) (NeuralNetwork2.initParams 0.5 nn2)
--    out = 
  in
    do
--      store <- initAccMetrics
--      registerGcMetrics store -- optional
--      server <- forkServerWith store "localhost" 8001
--      writeFile "file.dot" $ showDot (fglToDot $ (toFGL nn2 :: Gr Label Label))
      --print $ run $ A.zipWith (A.-) (gradient2 s1 s1 nn2 e (Prelude.map NeuralNetwork2.pFlatten i)) (gradient s1 s1 nn2 e (Prelude.map NeuralNetwork2.pFlatten i))
      --mapM_ (print . (Debug.Trace.trace "run") . run) $ forward' s1 s1 nn2 (use p) (Prelude.map pFlatten i)
      case nn2 of
        SomeNeuralNetwork p1 p2 sl sw si ss so nn -> print $ show $ pFlatten $ evalBackward sl nn (NeuralNetwork2.init 0 sl) (NeuralNetwork2.init 0 sl)
      --print $ show $ forward s1 s1 nn2 e (NeuralNetwork2.initParams 0.5 nn2) (Prelude.map NeuralNetwork2.flatten i)
