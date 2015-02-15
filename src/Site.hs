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
routes = [("LibraryFreedomForm", form),("numOfAttendees",writeText . T.pack . show =<< query NumOfAttendees), ("LibraryFreedomFormStatic", serveDirectory "static"),("", form)]



throwLeftDecode :: Either String OpenSshPublicKey -> PublicKey
throwLeftDecode (Right (OpenSshPublicKeyRsa k _)) = k
throwLeftDecode (Right _) = error "Wrong key type"
throwLeftDecode (Left s)  = error $ "Error reading keys: " ++ s


n::Int
n = 1024
    
    
encryptfield :: SystemRandom -> PublicKey-> String -> ByteString
encryptfield gen key field = toStrict $ fst $ RSA.encrypt gen key $ pack field

encryptAttendee :: SystemRandom -> Attendee -> PublicKey -> AttendeeEncrypted
encryptAttendee gen attendee key = AttendeeEncrypted{enc_name=encryptfield gen key (show $ name attendee) , enc_emailAddress = encryptfield gen key (show $ emailAddress attendee), enc_library = encryptfield gen key (show $ library attendee)}

attendeeForm :: Monad m => Form T.Text m Attendee
attendeeForm = Attendee
    <$> "name"      .: text Nothing
    <*> "email"      .: text Nothing
    <*> "library"  .: text Nothing

countSplice ::Monad n => Int -> I.Splice n
countSplice i = I.textSplice $ T.pack $ show i
            
form :: Handler App App ()
form = do
    liftIO $ print "Form"
    (view, result) <- runForm "LibraryFreedomForm" attendeeForm
    case result of
      Just new_vol -> do key_text <-liftIO $ readFile "Library.pub"
                         new_gen <- liftIO $ newGenIO
                         update (AddAttendee (encryptAttendee new_gen new_vol (throwLeftDecode $ decodePublic (toStrict $ pack key_text))))
                         serveFile "static/thankyou.html"
      Nothing -> do num <- query NumOfAttendees
                    heistLocal (I.bindSplice "count" (countSplice num) . bindDigestiveSplices view) $ render "libraryForm"

------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "Encrypted Library Freedom Registration App" "A sign up app where data is encrypted at rest" Nothing $ do
    addRoutes routes
    h <- nestSnaplet "" heist $ heistInit "templates"
    ac <- nestSnaplet "acid" acid $ acidInit (Database [])
    return $ App h ac

