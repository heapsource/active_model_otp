class User
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::Otp

  define_model_callbacks :create
  attr_accessor :otp_secret_key

  has_one_time_password

end
