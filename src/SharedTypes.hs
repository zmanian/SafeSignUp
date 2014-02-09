{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveDataTypeable  #-}

module SharedTypes(Volunteer(..),VolunteerEncrypted(..), Database(..), putCopy, getCopy,addVolunteer) where

import qualified Data.Text as T
import           Data.ByteString (ByteString)
import Data.SafeCopy
import Control.Applicative
import           Data.Typeable (Typeable)
import           Control.Monad.State( get, put )

import           Snap.Snaplet.AcidState (Update, Query, Acid,
                 HasAcid (getAcidStore), makeAcidic, update, query, acidInit)



data Database = Database [VolunteerEncrypted] deriving(Show, Typeable)

addVolunteer :: VolunteerEncrypted ->  Update Database ()
addVolunteer vol
    = do Database volunteers <- get
         put $ Database (vol:volunteers)

data Volunteer = Volunteer
     {alias   :: T.Text
    , emailAddress :: T.Text
    , phoneNumber  :: T.Text
    , feb24thNight  :: Bool
    , feb25thMorning  :: Bool
    , feb25thLunch  :: Bool
    , feb26thMorning  :: Bool
    , feb26thLunch  :: Bool
    } deriving (Show,Typeable)

data VolunteerEncrypted = VolunteerEncrypted
    {enc_alias   :: ByteString
    , enc_emailAddress :: ByteString
    , enc_phoneNumber  :: ByteString
    , enc_feb24thNight  :: ByteString
    , enc_feb25thMorning  :: ByteString
    , enc_feb25thLunch  :: ByteString
    , enc_feb26thMorning  :: ByteString
    , enc_feb26thLunch  :: ByteString
    } deriving (Show,Typeable)

instance SafeCopy VolunteerEncrypted where
    putCopy VolunteerEncrypted{..} = contain $ do safePut enc_alias; safePut enc_emailAddress; safePut enc_feb24thNight; safePut enc_feb24thNight; safePut enc_feb25thMorning; safePut enc_feb25thLunch;safePut enc_feb26thMorning;safePut enc_feb26thLunch;
    getCopy = contain $ VolunteerEncrypted <$> safeGet <*> safeGet<*> safeGet <*> safeGet<*> safeGet<*> safeGet <*> safeGet<*> safeGet

