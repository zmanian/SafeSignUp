{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

------------------------------------------------------------------------------
-- | This module defines our application's state type and an alias for its
-- handler monad.
module Application where

------------------------------------------------------------------------------
import Control.Lens
import Snap.Snaplet
import Snap.Snaplet.Heist
import Snap.Snaplet.AcidState
import SharedTypes
import Data.SafeCopy
import Control.Applicative

deriveSafeCopy 0 'base ''Database
makeAcidic ''Database[]


------------------------------------------------------------------------------
data App = App
    { _heist :: Snaplet (Heist App),
      _acid :: Snaplet (Acid Database)
    }

makeLenses ''App

instance HasHeist App where
    heistLens = subSnaplet heist

instance HasAcid App Database where
    getAcidStore  = view (acid.snapletValue)


------------------------------------------------------------------------------
type AppHandler = Handler App App

