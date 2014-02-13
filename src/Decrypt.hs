import           Crypto.PubKey.OpenSsh (decodePrivate, OpenSshPrivateKey(..))
import           Crypto.Types.PubKey.RSA (PrivateKey)
import           Crypto.Random
import qualified Codec.Crypto.RSA as RSA 
import           SharedTypes
import           Data.ByteString.Char8
import           Data.Text.Encoding
import           Data.Text

decryptfield :: PrivateKey-> ByteString -> Text
decryptfield key field = decodeUtf8 $ RSA.decrypt key field

decryptfield :: PrivateKey-> ByteString -> Bool
decryptfield key field = read $ unpack $ RSA.decrypt key field

decryptVolunteer::VolunteerEncrypted -> PrivateKey ->Volunteer 
decryptVolunteer enc_volunteer key = Volunteer{alias=decryptfield enc_alias enc_volunteer) , emailAddress = decryptfield key  emailAddress volunteer), phoneNumber = decryptfield key enc_phoneNumber enc_volunteer), feb24thNight = decryptfield key enc_feb24thNight enc_volunteer),feb25thMorning = decryptfield key enc_feb25thMorning enc_volunteer),feb25thLunch = decryptfield key enc_feb25thLunch enc_volunteer),feb26thMorning = decryptfield key enc_feb26thMorning enc_volunteer),feb26thLunch = decryptfield key enc_feb26thLunch enc_volunteer) }


decryptDatabase:: Database -> PrivateKey -> [Volunteer]
decryptDatabase (Database enc_vols) key = fmap decryptVolunteer enc_vols

throwLeftDecode :: Either String OpenSshPrivateKey -> PrivateKey
throwLeftDecode (Right (OpenSshPrivateKeyRsa k _)) = k
throwLeftDecode (Right _) = error "Wrong key type"
throwLeftDecode (Left s)  = error $ "Error reading keys: " ++ s

main:: IO()
main = do
  key_text <-liftIO $ readFile "Volunteers"
  database <- openLocalStateFrom "state/" (Database [])
  mapM print.show $ decryptDatabase database $ throwLeftDecode $ decodePrivate key_text 
