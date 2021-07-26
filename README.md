[![Active Model OTP](https://github.com/heapsource/active_model_otp/actions/workflows/active_model_otp.yml/badge.svg?branch=main)](https://github.com/heapsource/active_model_otp/actions/workflows/active_model_otp.yml)
[![Gem Version](https://badge.fury.io/rb/active_model_otp.svg)](http://badge.fury.io/rb/active_model_otp)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)


# ActiveModel::Otp

**ActiveModel::Otp** makes adding **Two Factor Authentication** (TFA) to a model simple. Let's see what's required to get AMo::Otp working in our Application, using Rails 5.0 (AMo::Otp is also compatible with Rails 4.x versions). We're going to use a User model and try to add options provided by **ActiveModel::Otp**. Inspired by AM::SecurePassword

## Dependencies

* [ROTP](https://github.com/mdp/rotp) 6.2.0 or higher
* Ruby 2.3 or greater

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
class User < ApplicationRecord
  has_one_time_password
end
```

Note: If you're adding this to an existing user model you'll need to generate *otp_secret_key* with a migration like:
```ruby
User.find_each { |user| user.update_attribute(:otp_secret_key, User.otp_random_secret) }
```

To use a custom column to store the secret key field you can use the column_name option. It is also possible to generate codes with a specified length.

```ruby
class User < ApplicationRecord
  has_one_time_password column_name: :my_otp_secret_column, length: 4
end
```

## Usage

The has_one_time_password statement provides to the model some useful methods in order to implement our TFA system. AMo:Otp generates one time passwords according to [TOTP RFC 6238](https://tools.ietf.org/html/rfc6238) and the [HOTP RFC 4226](https://www.ietf.org/rfc/rfc4226). This is compatible with Google Authenticator apps available for Android and iPhone, and now in use on GMail.

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

Set default value for otp_counter to 0.
```ruby
change_column :users, :otp_counter, :integer, default: 0
```

In addition set the counter flag option to true

```ruby
class User < ApplicationRecord
  has_one_time_password counter_based: true
end
```

And for a custom counter column

```ruby
class User < ApplicationRecord
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

## Backup codes

We're going to add a field to our ``User`` Model, so each user can have an otp backup codes. The next step is to run the migration generator in order to add the backup codes field.

```ruby
rails g migration AddOtpBackupCodesToUsers otp_backup_codes:text
=>
      invoke  active_record
      create    db/migrate/20210126030834_add_otp_backup_codes_to_users.rb
```

You can change backup codes column name by option `backup_codes_column_name`:

```ruby
class User < ApplicationRecord
  has_one_time_password backup_codes_column_name: 'secret_codes'
end
```

Then use array type in schema or serialize attribute in model as Array (depending on used db type). Or even consider to use some libs like (lockbox)[https://github.com/ankane/lockbox] with type array.

After that user can use one of automatically generated backup codes for authentication using same method `authenticate_otp`.

By default it generates 12 backup codes. You can change it by option `backup_codes_count`:

```ruby
class User < ApplicationRecord
  has_one_time_password backup_codes_count: 6
end
```

By default each backup code can be reused an infinite number of times. You can
change it with option `one_time_backup_codes`:

```ruby
class User < ApplicationRecord
  has_one_time_password one_time_backup_codes: true
end
```

```ruby
user.authenticate_otp('186522') # => true
user.authenticate_otp('186522') # => false
```

## Google Authenticator Compatible

The library works with the Google Authenticator iPhone and Android app, and also includes the ability to generate provisioning URI's to use with the QR Code scanner built into the app.

```ruby
# Use your user's email address to generate the provisioning_url
user.provisioning_uri # => 'otpauth://totp/hello@heapsource.com?secret=2z6hxkdwi3uvrnpn'

# Use a custom field to generate the provisioning_url
user.provisioning_uri("hello") # => 'otpauth://totp/hello?secret=2z6hxkdwi3uvrnpn'

# You can customize the generated url, by passing a hash of Options
# `:issuer` lets you set the Issuer name in Google Authenticator, so it doesn't show as a blank entry.
user.provisioning_uri(nil, issuer: 'MYAPP') #=> 'otpauth://totp/hello@heapsource.com?secret=2z6hxkdwi3uvrnpn&issuer=MYAPP'
```

This can then be rendered as a QR Code which can be scanned and added to the users list of OTP credentials.

### Setting up a customer interval 

If you define a custom interval for TOTP codes, just as `has_one_time_password interval: 10` (for example), remember to include the interval also in `provisioning_uri` method. If not defined, the default value is 30 seconds (according to ROTP gem: https://github.com/mdp/rotp/blob/master/lib/rotp/totp.rb#L9)

```ruby
class User < ApplicationRecord
  has_one_time_password interval: 10 # the interval value is in seconds
end

user = User.new
user.provisioning_uri("hello", interval: 10) # => 'otpauth://totp/hello?secret=2z6hxkdwi3uvrnpn&period=10'

# This code snippet generates OTP codes that expires every 10 seconds.
```

**Note**: Only some authenticator apps are compatible with custom `period` of tokens, for more details check these links:

- https://labanskoller.se/blog/2019/07/11/many-common-mobile-authenticator-apps-accept-qr-codes-for-modes-they-dont-support
- https://www.ibm.com/docs/en/sva/9.0.7?topic=authentication-configuring-totp-one-time-password-mechanism

So, be careful and aware when using custom intervals/periods for your TOTP codes beyond the default 30 seconds :)

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
- [Drifting Ruby Tutorial](https://www.driftingruby.com/episodes/two-factor-authentication)
- [Generate QR code with rqrcode gem](https://github.com/heapsource/active_model_otp/wiki/Generate-QR-code-with-rqrcode-gem)
- Generating QR Code with Google Charts API
- [Sending code via SMS with Twilio](https://github.com/heapsource/active_model_otp/wiki/Send-code-via-Twilio-SMS)
- [Using with Mongoid](https://github.com/heapsource/active_model_otp/wiki/Using-with-Mongoid)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
