class UserWithEncryptedCodes
  extend ActiveModel::Callbacks
  include ActiveModel::Serializers::JSON
  include ActiveModel::Validations
  include ActiveModel::OneTimePassword

  define_model_callbacks :create
  attr_accessor :otp_secret_key, :otp_backup_codes, :email

  has_one_time_password backup_codes_encrypted: true
end
