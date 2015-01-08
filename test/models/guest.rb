class Guest
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::OneTimePassword

  define_model_callbacks :create
  attr_accessor :otp_secret_key, :email

  has_one_time_password interval: 60
end

