{-# LANGUAGE OverloadedStrings #-}

------------------------------------------------------------------------------
-- | This module is where all the routes and handlers are defined for your
-- site. The 'app' function is the initializer that combines everything
-- together and is exported by this module.
module Site
  ( app
  ) where

------------------------------------------------------------------------------
import           Control.Applicative
import           Data.ByteString (ByteString)
import           Data.ByteString.Lazy (toStrict)
import           Data.ByteString.Lazy.Char8 (pack)
import qualified Data.Text as T
import           Snap.Core
import           Snap.Snaplet
import           Snap.Snaplet.Auth
import           Snap.Snaplet.Auth.Backends.JsonFile
import           Snap.Snaplet.Heist
import           Snap.Snaplet.Session.Backends.CookieSession
import           Snap.Util.FileServe
import           Heist
import qualified Heist.Interpreted as I
------------------------------------------------------------------------------
import           Application
import           Text.Digestive
import           Text.Digestive.Heist
import           Text.Digestive.Snap
import qualified Codec.Crypto.RSA as RSA 
import           Crypto.PubKey.OpenSsh (decodePublic, OpenSshPublicKey)
import           Crypto.Types.PubKey.RSA (PublicKey)
import           Crypto.Random
import           SharedTypes
import           Snap.Snaplet.AcidState (Update, Query, Acid,
                 HasAcid (getAcidStore), makeAcidic, update, query, acidInit)
------------------------------------------------------------------------------
-- | The application's routes.
routes :: [(ByteString, Handler App App ())]
routes = [("/", form)]




n::Int
n = 1024    
    
    
encyptfield :: SystemRandom -> PublicKey-> String -> ByteString
encyptfield gen key field = toStrict $ fst $ RSA.encrypt gen key $ pack field

encryptVolunteer::SystemRandom -> Volunteer -> PublicKey ->VolunteerEncrypted 
encryptVolunteer gen volunteer key = VolunteerEncrypted{enc_alias=encyptfield gen key (show $ alias  volunteer) , enc_emailAddress = encyptfield gen key (show $ emailAddress volunteer), enc_phoneNumber = encyptfield gen key (show $ phoneNumber volunteer), enc_feb24thNight =encyptfield gen key (show $ feb24thNight volunteer),enc_feb25thMorning =encyptfield gen key (show $ phoneNumber volunteer),enc_feb25thLunch =encyptfield gen key (show $ feb25thLunch volunteer),enc_feb26thMorning =encyptfield gen key (show $ feb26thMorning volunteer),enc_feb26thLunch =encyptfield gen key (show $ feb26thLunch volunteer) }

volunteerForm :: Monad m => Form T.Text m Volunteer
volunteerForm = Volunteer
    <$> "Alias"      .: text Nothing
    <*> "Email"      .: text Nothing
    <*> "Phone Number"  .: text Nothing
    <*> "Feb 24th Night" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb 25th Morning" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb 25th Lunch" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb 26th Morning" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb 26th Lunch" .: choice [(True, "Yes"), (False, "No")] Nothing


form :: Handler App App ()
form = do
    -- readFile  "Volunteer.pub_key" >>= decodePublic
    (_, result) <- runForm "form" volunteerForm
    -- print encryptVolunteer result
    render "Test.html"

------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "Encrypted Volunteer App" "A volunteer sign up app where data is encrypted at rest" Nothing $ do
    h <- nestSnaplet "" heist $ heistInit "templates"
    ac <- nestSnaplet "acid" acid $ acidInit (Database [])
    addRoutes routes
    return $ App h ac

