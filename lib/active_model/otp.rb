module ActiveModel
  module Otp
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one_time_password(options = {})

        cattr_accessor :otp_column_name

        self.otp_column_name = (options[:column_name] || "otp_secret_key").to_s

        include InstanceMethodsOnActivation

        before_create { self.otp_secret_key = ROTP::Base32.random_base32 }

        if respond_to?(:attributes_protected_by_default)
          def self.attributes_protected_by_default #:nodoc:
            super + [self.otp_column_name]
          end
        end
      end
    end

    module InstanceMethodsOnActivation
      def authenticate_otp(code)
        ROTP::TOTP.new(self.otp_column).verify(code)
      end

      def provisioning_uri
        ROTP::TOTP.new(self.otp_column).provisioning_url(self.email)
      end

      def otp_column
        self.send(self.class.otp_secret_key)
      end

    end
  end
end
