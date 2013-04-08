# ActiveModel::Otp

Adds methods to set and authenticate against one time passwords. Inspired in AM::SecurePassword

## Installation

Add this line to your application's Gemfile:

    gem 'active_model_otp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_model_otp

## Usage

### Setting Model
Add otp_secret_key to your model:

    rails g migration AddOtpSecretKeyToUsers otp_secret_key:string

```ruby
class User < ActiveRecord::Base
  has_one_time_password
end
```

The otp_secret_key is saved automatically when a object is created

### Authenticating using a code

```ruby
user.authenticate_otp('186522') # => true
sleep 30
user.authenticate_otp('186522') # => false
```

### Authenticating using a slightly old code

```ruby
user.authenticate_otp('186522') # => true
sleep 30
user.authenticate_otp('186522', drift: 60) # => true
```

### Getting current code (ex. to send via SMS)

```ruby
user.otp_code # => '186522'
sleep 30
user.otp_code # => '850738'
```

### Getting provision URI (to generate QR codes compatibles with Google Authenticator app)

```ruby
user.provision_uri # => 'otpauth://totp/alice@google.com?secret=JBSWY3DPEHPK3PXP'
```

### Useful Examples

#### Generating QR Code with Google Charts API

#### Generating QR Code with rqrcode and chunky_png

#### Sendind code via email with Twilio

#### Using with Mongoid

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
