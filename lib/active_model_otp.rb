require "active_model"
require "rotp"
require "active_model/otp"

ActiveSupport.on_load(:active_record) do
  include ActiveModel::Otp
end
