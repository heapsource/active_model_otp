class Visitor
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::OneTimePassword

  define_model_callbacks :create
  attr_accessor :otp_token, :email

  has_one_time_password column_name: :otp_token, length: 4
end

