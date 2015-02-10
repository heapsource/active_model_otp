module ActiveModel
  module OneTimePassword
    extend ActiveSupport::Concern

    module ClassMethods

      def has_one_time_password(options = {})
        cattr_accessor :otp_column_name, :otp_counter_column_name
        class_attribute :otp_digits, :otp_counter_based

        self.otp_column_name = (options[:column_name] || "otp_secret_key").to_s
        self.otp_digits = options[:length] || 6

        self.otp_counter_based = (options[:counter_based] || false)
        self.otp_counter_column_name = (options[:counter_column_name] || "otp_counter").to_s

        include InstanceMethodsOnActivation

        before_create { self.otp_regenerate_secret if !self.otp_column}
        before_create { self.otp_regenerate_counter if self.otp_counter_based && !self.otp_counter}

        if respond_to?(:attributes_protected_by_default)
          def self.attributes_protected_by_default #:nodoc:
            super + [self.otp_column_name, self.otp_counter_column_name]
          end
        end
      end
    end

    module InstanceMethodsOnActivation
      def otp_regenerate_secret
        self.otp_column = ROTP::Base32.random_base32
      end
      def otp_regenerate_counter
        self.otp_counter = 0
      end

      def authenticate_otp(code, options = {})
        if self.otp_counter_based
          hotp = ROTP::HOTP.new(self.otp_column, {digits: self.otp_digits})
          result = hotp.verify(code, self.otp_counter)
          if result && !options[:auto_increment] #auto_increment default is false, don't update
            self.otp_counter += 1
          end
          result
        else
          totp = ROTP::TOTP.new(self.otp_column, {digits: self.otp_digits})
          if drift = options[:drift]
            totp.verify_with_drift(code, drift)
          else
            totp.verify(code)
          end
        end
      end

      def otp_code(options = {})
        if self.otp_counter_based
          if options[:auto_increment]
            self.otp_counter += 1
          end
          ROTP::HOTP.new(self.otp_column, {digits: self.otp_digits}).at(self.otp_counter)
        else
          if options.is_a? Hash
            time = options.fetch(:time, Time.now)
            padding = options.fetch(:padding, true)
          else
            time = options
            padding = true
          end
          ROTP::TOTP.new(self.otp_column, {digits: self.otp_digits}).at(time, padding)
        end
      end

      def provisioning_uri(account = nil, options={})
        account ||= self.email if self.respond_to?(:email)

        if self.otp_counter_based
          ROTP::HOTP.new(self.otp_column, options).provisioning_uri(account)
        else
          ROTP::TOTP.new(self.otp_column, options).provisioning_uri(account)
        end
      end

      def otp_column
        self.send(self.class.otp_column_name)
      end

      def otp_column=(attr)
        self.send("#{self.class.otp_column_name}=", attr)
      end

      def otp_counter
        self.send(self.class.otp_counter_column_name)
      end

      def otp_counter=(attr)
        self.send("#{self.class.otp_counter_column_name}=", attr)
      end
    end
  end
end
