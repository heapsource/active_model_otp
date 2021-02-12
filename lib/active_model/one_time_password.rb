module ActiveModel
  module OneTimePassword
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one_time_password(options = {})
        cattr_accessor :otp_column_name, :otp_counter_column_name,
                       :otp_backup_codes_column_name
        class_attribute :otp_digits, :otp_counter_based,
                        :otp_backup_codes_count, :otp_one_time_backup_codes

        self.otp_column_name = (options[:column_name] || "otp_secret_key").to_s
        self.otp_digits = options[:length] || 6

        self.otp_counter_based = (options[:counter_based] || false)
        self.otp_counter_column_name = (options[:counter_column_name] || "otp_counter").to_s

        self.otp_backup_codes_column_name = (
          options[:backup_codes_column_name] || 'otp_backup_codes'
        ).to_s
        self.otp_backup_codes_count = options[:backup_codes_count] || 12
        self.otp_one_time_backup_codes = (
          options[:one_time_backup_codes] || false
        )

        include InstanceMethodsOnActivation

        before_create(**options.slice(:if, :unless)) do
          self.otp_regenerate_secret if !otp_column
          self.otp_regenerate_counter if otp_counter_based && !otp_counter
          otp_regenerate_backup_codes if backup_codes_enabled?
        end

        if respond_to?(:attributes_protected_by_default)
          def self.attributes_protected_by_default #:nodoc:
            super + [otp_column_name, otp_counter_column_name]
          end
        end
      end

      # Defaults to 160 bit long secret
      # (meaning a 32 character long base32 secret)
      def otp_random_secret(length = 20)
        ROTP::Base32.random(length)
      end
    end

    module InstanceMethodsOnActivation
      def otp_regenerate_secret
        self.otp_column = self.class.otp_random_secret
      end

      def otp_regenerate_counter
        self.otp_counter = 1
      end

      def authenticate_otp(code, options = {})
        return true if backup_codes_enabled? && authenticate_backup_code(code)

        if otp_counter_based
          hotp = ROTP::HOTP.new(otp_column, digits: otp_digits)
          result = hotp.verify(code, otp_counter)
          if result && options[:auto_increment]
            self.otp_counter += 1
            save if respond_to?(:changed?) && !new_record?
          end
          result
        else
          totp = ROTP::TOTP.new(otp_column, digits: otp_digits)
          if drift = options[:drift]
            totp.verify(code, drift_behind: drift)
          else
            totp.verify(code)
          end
        end
      end

      def otp_code(options = {})
        if otp_counter_based
          if options[:auto_increment]
            self.otp_counter += 1
            save if respond_to?(:changed?) && !new_record?
          end
          ROTP::HOTP.new(otp_column, digits: otp_digits).at(self.otp_counter)
        else
          if options.is_a? Hash
            time = options.fetch(:time, Time.now)
          else
            time = options
          end
          ROTP::TOTP.new(otp_column, digits: otp_digits).at(time)
        end
      end

      def provisioning_uri(account = nil, options = {})
        account ||= self.email if self.respond_to?(:email)
        account ||= ""

        if otp_counter_based
          ROTP::HOTP.new(otp_column, options).provisioning_uri(account)
        else
          ROTP::TOTP.new(otp_column, options).provisioning_uri(account)
        end
      end

      def otp_column
        self.public_send(self.class.otp_column_name)
      end

      def otp_column=(attr)
        self.public_send("#{self.class.otp_column_name}=", attr)
      end

      def otp_counter
        if self.class.otp_counter_column_name != "otp_counter"
          self.public_send(self.class.otp_counter_column_name)
        else
          super
        end
      end

      def otp_counter=(attr)
        if self.class.otp_counter_column_name != "otp_counter"
          self.public_send("#{self.class.otp_counter_column_name}=", attr)
        else
          super
        end
      end

      def serializable_hash(options = nil)
        options ||= {}
        options[:except] = Array(options[:except])
        options[:except] << self.class.otp_column_name
        super(options)
      end

      def otp_regenerate_backup_codes
        otp = ROTP::OTP.new(otp_column)
        backup_codes = Array.new(self.class.otp_backup_codes_count) do
          otp.generate_otp((SecureRandom.random_number(9e5) + 1e5).to_i)
        end

        public_send("#{self.class.otp_backup_codes_column_name}=", backup_codes)
      end

      def backup_codes_enabled?
        self.class.attribute_method?(self.class.otp_backup_codes_column_name)
      end

      private

      def authenticate_backup_code(code)
        backup_codes_column_name = self.class.otp_backup_codes_column_name
        backup_codes = public_send(backup_codes_column_name)
        return false unless backup_codes.include?(code)

        if self.class.otp_one_time_backup_codes
          backup_codes.delete(code)
          public_send("#{backup_codes_column_name}=", backup_codes)
          save if respond_to?(:changed?) && !new_record?
        end

        true
      end
    end
  end
end
