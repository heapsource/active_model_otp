# frozen_string_literal: true

class AfterUser < ActiveRecord::Base
  has_one_time_password after_column_name: :last_otp_at
end
