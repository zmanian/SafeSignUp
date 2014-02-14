{-# LANGUAGE TypeFamilies, DeriveDataTypeable, TemplateHaskell #-}

import           Crypto.PubKey.OpenSsh (decodePrivate, OpenSshPrivateKey(..))
import           Crypto.Types.PubKey.RSA (PrivateKey)
import           Crypto.Random
import qualified Codec.Crypto.RSA as RSA 
import           SharedTypes
import           Data.ByteString.Lazy.Char8 as L
import           Data.ByteString.Char8 as B
import           Data.Text.Encoding as E
import           Data.Text as T
import           Control.Monad.Trans
import           Data.Acid
import           Data.ByteString.Lazy (toStrict, toChunks )
import           Data.SafeCopy
import           Application

decryptfieldText :: PrivateKey-> B.ByteString -> Text 
decryptfieldText key field = E.decodeUtf8 $ toStrict $ RSA.decrypt key ( L.pack $ B.unpack field)

decryptfieldBool :: PrivateKey-> B.ByteString -> Bool 
decryptfieldBool key field = read $ L.unpack $ RSA.decrypt key (L.pack $ B.unpack field)

decryptVolunteer:: PrivateKey -> VolunteerEncrypted ->Volunteer 
decryptVolunteer key enc_volunteer = Volunteer{alias = decryptfieldText key (enc_alias enc_volunteer) , emailAddress = decryptfieldText key (enc_emailAddress enc_volunteer), phoneNumber = decryptfieldText key (enc_phoneNumber enc_volunteer), feb24thNight = decryptfieldBool key (enc_feb24thNight enc_volunteer),feb25thMorning = decryptfieldBool key (enc_feb25thMorning enc_volunteer),feb25thLunch = decryptfieldBool key (enc_feb25thLunch enc_volunteer),feb26thMorning = decryptfieldBool key (enc_feb26thMorning enc_volunteer),feb26thLunch = decryptfieldBool key (enc_feb26thLunch enc_volunteer) }


-- decryptDatabase:: AcidState Database -> PrivateKey -> [Volunteer]
-- decryptDatabase (Database enc_vols) key = fmap (decryptVolunteer key) enc_vols

throwLeftDecode :: Either String OpenSshPrivateKey -> PrivateKey
throwLeftDecode (Right (OpenSshPrivateKeyRsa k )) = k
throwLeftDecode (Right _) = error "Wrong key type"
throwLeftDecode (Left s)  = error $ "Error reading keys: " ++ s

main:: IO ()
main = do
  key_text <-liftIO $ Prelude.readFile "Volunteers"
  database <- openLocalStateFrom "state/Database/" (Database [])
  vols <- query database GetVolunteers
  print $ fmap show $ fmap (decryptVolunteer $ throwLeftDecode $ decodePrivate $ B.pack key_text) vols
