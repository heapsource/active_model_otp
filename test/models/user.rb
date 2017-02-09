class User
  extend ActiveModel::Callbacks
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml
  include ActiveModel::Validations
  include ActiveModel::OneTimePassword

  define_model_callbacks :create
  attr_accessor :otp_secret_key, :email

  has_one_time_password
  def attributes
    { "otp_secret_key" => otp_secret_key, "email" => email }
  end
end
