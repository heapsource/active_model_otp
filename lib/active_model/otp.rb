module ActiveModel
  module Otp
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one_time_password(options = {})
        include InstanceMethodsOnActivation

        before_create { self.otp_secret_key = ROTP::Base32.random_base32 }

        if respond_to?(:attributes_protected_by_default)
          def self.attributes_protected_by_default #:nodoc:
            super + ['otp_secret_key']
          end
        end
      end
    end

    module InstanceMethodsOnActivation
      def authenticate_otp(code)
        ROTP::TOTP.new(self.otp_secret_key).verify(code)
      end

      def provisioning_uri
        ROTP::TOTP.new(self.otp_secret_key).provisioning_url(self.email)
      end
    end
  end
end
