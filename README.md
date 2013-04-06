# HasOneTimePassword

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'active_model_otp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_model_otp

## Usage

### Setting Model
Add otp_secret_key to your model

    rails g migration AddOtpSecretKeyToUsers otp_secret_key:string

```ruby
class User < ActiveRecord::Base
  has_otp_password
end
```

### Authenticating using a code

```ruby
user.authenticate_otp('123456') # => true
sleep 30
user.authenticate_otp('123456') # => false
```

### Getting current code (ex. to send via SMS)

```ruby
user.otp_code # => '123456'
```

### Getting provision URI (to generate QR codes compatibles with Google Authenticator app)

```ruby
user.provision_uri # => 'otpauth://totp/alice@google.com?secret=JBSWY3DPEHPK3PXP'
```

### Useful Examples

#### Generating QR Code with Google Charts API

#### Generating QR Code with rqrcode and chunky_png

#### Sendind code via email with Twilio

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
