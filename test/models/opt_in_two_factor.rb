# frozen_string_literal: true

class OptInTwoFactor
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::OneTimePassword

  define_model_callbacks :create
  attr_accessor :otp_secret_key, :email

  has_one_time_password unless: :otp_opt_in?

  def otp_opt_in?
    true
  end
end
