require "active_model"
require "active_support/core_ext/class/attribute_accessors"
require "rotp"
require "active_model/otp"

ActiveSupport.on_load(:active_record) do
  include ActiveModel::Otp
end
