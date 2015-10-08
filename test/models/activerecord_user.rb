class ActiverecordUser < ActiveRecord::Base
  has_one_time_password counter_based: true
end
