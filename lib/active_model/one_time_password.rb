module ActiveModel
  module OneTimePassword
    extend ActiveSupport::Concern

    module ClassMethods

      def has_one_time_password(options = {})

        cattr_accessor :otp_column_name
        class_attribute :otp_digits

        self.otp_column_name = (options[:column_name] || "otp_secret_key").to_s
        self.otp_digits = options[:length] || 6

        include InstanceMethodsOnActivation

        before_create { self.otp_regenerate_secret if !self.otp_column}

        if respond_to?(:attributes_protected_by_default)
          def self.attributes_protected_by_default #:nodoc:
            super + [self.otp_column_name]
          end
        end
      end
    end

    module InstanceMethodsOnActivation
      def otp_regenerate_secret
        self.otp_column = ROTP::Base32.random_base32
      end

      def authenticate_otp(code, options = {})
        totp = ROTP::TOTP.new(self.otp_column, {digits: self.otp_digits})
        if drift = options[:drift]
          totp.verify_with_drift(code, drift)
        else
          totp.verify(code)
        end
      end

      def otp_code(options = {})
        if options.is_a? Hash
          time = options.fetch(:time, Time.now)
          padding = options.fetch(:padding, true)
        else
          time = options
          padding = true
        end
        ROTP::TOTP.new(self.otp_column, {digits: self.otp_digits}).at(time, padding)
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
