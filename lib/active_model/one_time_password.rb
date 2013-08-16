module ActiveModel
  module OneTimePassword
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one_time_password(options = {})

        cattr_accessor :otp_column_name
        self.otp_column_name = (options[:column_name] || "otp_secret_key").to_s

        include InstanceMethodsOnActivation

        before_create { self.otp_column = ROTP::Base32.random_base32 }

        if respond_to?(:attributes_protected_by_default)
          def self.attributes_protected_by_default #:nodoc:
            super + [self.otp_column_name]
          end
        end
      end
    end

    module InstanceMethodsOnActivation
      def authenticate_otp(code, options = {})
        totp = ROTP::TOTP.new(self.otp_column)
        if drift = options[:drift]
          totp.verify_with_drift(code, drift)
        else
          totp.verify(code)
        end
      end

      def otp_code(time = Time.now)
        ROTP::TOTP.new(self.otp_column).at(time)
      end

      def provisioning_uri(account = nil)
        account ||= self.email if self.respond_to?(:email)
        ROTP::TOTP.new(self.otp_column).provisioning_uri(account)
      end

      def otp_column
        self.send(self.class.otp_column_name)
      end

      def otp_column=(attr)
        self.send("#{self.class.otp_column_name}=", attr)
      end

    end
  end
end
