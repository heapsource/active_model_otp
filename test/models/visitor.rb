class Visitor
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::Otp

  define_model_callbacks :create
  attr_accessor :otp_token

  has_one_time_password :column_name  => :otp_token

end

