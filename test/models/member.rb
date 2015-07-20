class Member
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::OneTimePassword

  define_model_callbacks :create
  attr_accessor :otp_secret_key, :otp_counter, :email

  has_one_time_password counter_based: true
end
