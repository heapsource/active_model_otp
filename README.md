[![Build Status](https://travis-ci.org/heapsource/active_model_otp.png)](https://travis-ci.org/heapsource/active_model_otp)
[![Gem Version](https://badge.fury.io/rb/active_model_otp.svg)](http://badge.fury.io/rb/active_model_otp)
[![Dependency Status](https://gemnasium.com/heapsource/active_model_otp.svg)](https://gemnasium.com/heapsource/active_model_otp)
[![Code Climate](https://codeclimate.com/github/heapsource/active_model_otp/badges/gpa.svg)](https://codeclimate.com/github/heapsource/active_model_otp)


# ActiveModel::Otp

**ActiveModel::Otp** makes adding **Two Factor Authentication** (TFA) to a model simple. Let's see what's required to get AMo::Otp working in our Application, using Rails 4.0 (AMo::Otp is also compatible with Rails 3.x versions). We're going to use a User model and some authentication to do it. Inspired by AM::SecurePassword

## Installation

Add this line to your application's Gemfile:

    gem 'active_model_otp'

And then execute:

    $ bundle

Or install it yourself as follows:

    $ gem install active_model_otp

## Setting your Model

We're going to add a field to our ``User`` Model, so each user can have an otp secret key. The next step is to run the migration generator in order to add the secret key field.

```ruby
rails g migration AddOtpSecretKeyToUsers otp_secret_key:string
=>
      invoke  active_record
      create    db/migrate/20130707010931_add_otp_secret_key_to_users.rb
```

We’ll then need to run rake db:migrate to update the users table in the database. The next step is to update the model code. We need to use has_one_time_password to make it use TFA.

```ruby
class User < ActiveRecord::Base
  has_one_time_password
end
```

Note: If you're adding this to an existing user model you'll need to generate *otp_secret_key* with a migration like:
```ruby
User.all.each { |user| user.update_attribute(:otp_secret_key, ROTP::Base32.random_base32) }
```

To use a custom column to store the secret key field you can use the column_name option. It is also possible to generate codes with a specified length.

```ruby
class User < ActiveRecord::Base
  has_one_time_password column_name: :my_otp_secret_column, length: 4
end
```

## Usage

The has_one_time_password statement provides to the model some useful methods in order to implement our TFA system. AMo:Otp generates one time passwords according to [TOTP RFC 6238](http://tools.ietf.org/html/rfc4226) and the [HOTP RFC 4226](http://tools.ietf.org/html/rfc4226). This is compatible with Google Authenticator apps available for Android and iPhone, and now in use on GMail.

The otp_secret_key is saved automatically when an object is created,

```ruby
user = User.create(email: "hello@heapsource.com")
user.otp_secret_key
 => "jt3gdd2qm6su5iqh"
```

**Note:** You can fork the applications for [iPhone](https://github.com/heapsource/google-authenticator) & [Android](https://github.com/heapsource/google-authenticator.android) and customize them

### Getting current code (e.g. to send via SMS)
```ruby
user.otp_code # => '186522'
sleep 30
user.otp_code # => '850738'

# Override current time
user.otp_code(time: Time.now + 3600) # => '317438'

# Don't zero-pad to six digits
user.otp_code(padding: false) # => '438'
```

### Authenticating using a code

```ruby
user.authenticate_otp('186522') # => true
sleep 30 # let's wait 30 secs
user.authenticate_otp('186522') # => false
```

### Authenticating using a slightly old code

```ruby
user.authenticate_otp('186522') # => true
sleep 30 # lets wait again
user.authenticate_otp('186522', drift: 60) # => true
```

## Counter based OTP

An additonal counter field is required in our ``User`` Model

```ruby
rails g migration AddCounterForOtpToUsers otp_counter:integer
=>
      invoke  active_record
      create    db/migrate/20130707010931_add_counter_for_otp_to_users.rb
```

In addition set the counter flag option to true

```ruby
class User < ActiveRecord::Base
  has_one_time_password counter_based: true
end
```

And for a custom counter column

```ruby
class User < ActiveRecord::Base
  has_one_time_password counter_based: true, counter_column_name: :my_otp_secret_counter_column
end
```

Authentication is done the same. You can manually adjust the counter for your usage or set auto_increment on success to true.

```ruby
user.authenticate_otp('186522') # => true
user.authenticate_otp('186522', auto_increment: true) # => true
user.authenticate_otp('186522') # => false
user.otp_counter -= 1
user.authenticate_otp('186522') # => true
```

When retrieving an ```otp_code``` you can also pass the ```auto_increment``` option.

```ruby
user.otp_code # => '186522'
user.otp_code # => '186522'
user.otp_code(auto_increment: true) # => '768273'
user.otp_code(auto_increment: true) # => '002811'
user.otp_code # => '002811'
```

## Google Authenticator Compatible

The library works with the Google Authenticator iPhone and Android app, and also includes the ability to generate provisioning URI's to use with the QR Code scanner built into the app.

```ruby
# Use your user's email address to generate the provisioning_url
user.provisioning_uri # => 'otpauth://totp/hello@heapsource.com?secret=2z6hxkdwi3uvrnpn'

# Use a custom field to generate the provisioning_url
user.provisioning_uri("hello") # => 'otpauth://totp/hello?secret=2z6hxkdwi3uvrnpn'
```

This can then be rendered as a QR Code which can be scanned and added to the users list of OTP credentials.

### Working example

Scan the following barcode with your phone, using Google Authenticator

![QRCODE](http://qrfree.kaywa.com/?l=1&s=8&d=otpauth%3A%2F%2Ftotp%2Froberto%40heapsource.com%3Fsecret%3D2z6hxkdwi3uvrnpn)

Now run the following and compare the output

```ruby
require "active_model_otp"
class User
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::OneTimePassword

  define_model_callbacks :create
  attr_accessor :otp_secret_key, :email

  has_one_time_password
end
user = User.new
user.email = 'roberto@heapsource.com'
user.otp_secret_key = "2z6hxkdwi3uvrnpn"
puts "Current code #{user.otp_code}"
```

**Note:** otp_secret_key must be generated using RFC 3548 base32 key strings (for compatilibity with google authenticator)

### Useful Examples

- [Generate QR code with rqrcode gem](https://github.com/heapsource/active_model_otp/wiki/Generate-QR-code-with-rqrcode-gem)
- Generating QR Code with Google Charts API
- [Sendind code via email with Twilio](https://github.com/heapsource/active_model_otp/wiki/Send-code-via-Twilio-SMS)
- [Using with Mongoid](https://github.com/heapsource/active_model_otp/wiki/Using-with-Mongoid)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
