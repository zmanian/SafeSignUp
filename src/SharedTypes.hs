{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE DeriveDataTypeable  #-}

module SharedTypes(Attendee(..),AttendeeEncrypted(..), Database(..), putCopy, getCopy,addAttendee, getAttendees,numOfAttendees) where

import qualified Data.Text as T
import           Data.ByteString (ByteString)
import Data.SafeCopy
import Control.Applicative
import           Data.Typeable (Typeable)
import           Control.Monad.State( get, put)
import           Control.Monad.Reader( ask )

import           Snap.Snaplet.AcidState (Update, Query, Acid,
                 HasAcid (getAcidStore), makeAcidic, update, query, acidInit)



data Database = Database [AttendeeEncrypted] deriving(Show, Typeable)

addAttendee :: AttendeeEncrypted ->  Update Database ()
addAttendee vol
    = do Database attendee <- get
         put $ Database (vol:attendee)
         
getAttendees :: Query Database [AttendeeEncrypted]
getAttendees = do Database attendees <- ask
                  return attendees

numOfAttendees :: Query Database Int
numOfAttendees = do Database attendees <- ask
                    return $ length attendees

data Attendee = Attendee
     {name   :: T.Text
    , emailAddress :: T.Text
    , library  :: T.Text
    } deriving (Show,Typeable)

data AttendeeEncrypted = AttendeeEncrypted
    {enc_name   :: ByteString
    , enc_emailAddress :: ByteString
    , enc_library  :: ByteString
    } deriving (Show,Typeable)

instance SafeCopy AttendeeEncrypted where
    
    putCopy AttendeeEncrypted{..} = contain $ do safePut enc_name; safePut enc_emailAddress; safePut enc_library;
    
    getCopy = contain $ AttendeeEncrypted <$> safeGet <*> safeGet<*> safeGet

