# frozen_string_literal: true

class IntervalUser < ActiveRecord::Base
  has_one_time_password interval: 2
end
