#unreleased
#v1.0.0
- Avoid overriding predefined otp_column value when initializing resource (Ilan Stern) https://github.com/heapsource/active_model_otp/pull/10
- Pad OTP codes with less than 6 digits (Johan Brissmyr) https://github.com/heapsource/active_model_otp/pull/7
- Get rid of deprecation warnings in Rails 4.1 (Nick DeMonner)

#v0.1.0
- OTP codes can be in 5 or 6 digits (André Luis Leal Cardoso Junior)
- Require 'cgi', rotp needs it for encoding parameters (André Luis Leal Cardoso Junior)
- Change column name for otp secret key (robertomiranda)
