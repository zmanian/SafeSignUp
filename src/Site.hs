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
import           Crypto.PubKey.OpenSsh (decodePublic, OpenSshPublicKey(..))
import           Crypto.Types.PubKey.RSA (PublicKey)
import           Crypto.Random
import           SharedTypes
import           Snap.Snaplet.AcidState (Update, Query, Acid, HasAcid (getAcidStore), makeAcidic, update, query, acidInit)
import           Control.Monad.Trans
import qualified Text.XmlHtml as X

------------------------------------------------------------------------------
-- | The application's routes.
routes :: [(ByteString, Handler App App ())]
routes = [("/RSACform", form),("/numOfVolunteers",writeText . T.pack . show =<< query NumOfVolunteers), ("/SafeSignUp", serveDirectory "static")] 



throwLeftDecode :: Either String OpenSshPublicKey -> PublicKey
throwLeftDecode (Right (OpenSshPublicKeyRsa k _)) = k
throwLeftDecode (Right _) = error "Wrong key type"
throwLeftDecode (Left s)  = error $ "Error reading keys: " ++ s


n::Int
n = 1024    
    
    
encryptfield :: SystemRandom -> PublicKey-> String -> ByteString
encryptfield gen key field = toStrict $ fst $ RSA.encrypt gen key $ pack field

encryptVolunteer::SystemRandom -> Volunteer -> PublicKey ->VolunteerEncrypted 
encryptVolunteer gen volunteer key = VolunteerEncrypted{enc_alias=encryptfield gen key (show $ alias  volunteer) , enc_emailAddress = encryptfield gen key (show $ emailAddress volunteer), enc_phoneNumber = encryptfield gen key (show $ phoneNumber volunteer), enc_feb24thNight =encryptfield gen key (show $ feb24thNight volunteer),enc_feb25thMorning =encryptfield gen key (show $ feb25thMorning volunteer),enc_feb25thLunch =encryptfield gen key (show $ feb25thLunch volunteer),enc_feb26thMorning =encryptfield gen key (show $ feb26thMorning volunteer),enc_feb26thLunch =encryptfield gen key (show $ feb26thLunch volunteer) }

volunteerForm :: Monad m => Form T.Text m Volunteer
volunteerForm = Volunteer
    <$> "alias"      .: text Nothing
    <*> "email"      .: text Nothing
    <*> "phone_number"  .: text Nothing
    <*> "Feb_24th_Night" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb_25th_Morning" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb_25th_Lunch" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb_26th_Morning" .: choice [(True, "Yes"), (False, "No")] Nothing
    <*> "Feb_26th_Lunch" .: choice [(True, "Yes"), (False, "No")] Nothing

countSplice ::Monad n => Int -> I.Splice n
countSplice i = I.textSplice $ T.pack $ show i
            
form :: Handler App App ()
form = do
    -- liftIO $ print "Form"
    (view, result) <- runForm "RSACform" volunteerForm
    case result of
      Just new_vol -> do key_text <-liftIO $ readFile "Volunteers.pub_key"
                         new_gen <- liftIO $ newGenIO
                         update (AddVolunteer (encryptVolunteer new_gen new_vol (throwLeftDecode $ decodePublic (toStrict $ pack key_text))))
                         writeBS "Success! and Encrypted"
      Nothing -> do num <- query NumOfVolunteers
                    heistLocal (I.bindSplice "count" (countSplice num) . bindDigestiveSplices view) $ render "volunteerForm"

------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "Encrypted Volunteer App" "A volunteer sign up app where data is encrypted at rest" Nothing $ do
    addRoutes routes
    h <- nestSnaplet "" heist $ heistInit "templates"
    ac <- nestSnaplet "acid" acid $ acidInit (Database [])
    return $ App h ac

