# frozen_string_literal: true

class DefaultIntervalUser < ActiveRecord::Base
  has_one_time_password
end
