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

decryptAttendee:: PrivateKey -> AttendeeEncrypted ->Attendee
decryptAttendee key enc_attendee = Attendee{name = decryptfieldText key (enc_name enc_attendee) , emailAddress = decryptfieldText key (enc_emailAddress enc_attendee), library = decryptfieldText key (enc_library enc_attendee)}

-- decryptDatabase:: AcidState Database -> PrivateKey -> [Volunteer]
-- decryptDatabase (Database enc_vols) key = fmap (decryptVolunteer key) enc_vols

throwLeftDecode :: Either String OpenSshPrivateKey -> PrivateKey
throwLeftDecode (Right (OpenSshPrivateKeyRsa k )) = k
throwLeftDecode (Right _) = error "Wrong key type"
throwLeftDecode (Left s)  = error $ "Error reading keys: " ++ s

main:: IO ()
main = do
  key_text <-liftIO $ Prelude.readFile "Libary.privkey"
  database <- openLocalStateFrom "state/Database/" (Database [])
  vols <- query database GetAttendees
  print $ fmap show $ fmap (decryptAttendee $ throwLeftDecode $ decodePrivate $ B.pack key_text) vols
