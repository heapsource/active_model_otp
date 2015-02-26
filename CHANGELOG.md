#v1.2.0
- Added Counter based OTP (HOTP) (@ResultsMayVary ) https://github.com/heapsource/active_model_otp/pull/19
- Adding options to provisioning uri, so we can include issuer (@doon) https://github.com/heapsource/active_model_otp/pull/15

#v1.1.0
- Add function to re-geterante the OTP secret (@TikiTDO) https://github.com/heapsource/active_model_otp/pull/14
- Added option to pass OTP length (@shivanibhanwal) https://github.com/heapsource/active_model_otp/pull/13

#v1.0.0
- Avoid overriding predefined otp_column value when initializing resource (Ilan Stern) https://github.com/heapsource/active_model_otp/pull/10
- Pad OTP codes with less than 6 digits (Johan Brissmyr) https://github.com/heapsource/active_model_otp/pull/7
- Get rid of deprecation warnings in Rails 4.1 (Nick DeMonner)

#v0.1.0
- OTP codes can be in 5 or 6 digits (André Luis Leal Cardoso Junior)
- Require 'cgi', rotp needs it for encoding parameters (André Luis Leal Cardoso Junior)
- Change column name for otp secret key (robertomiranda)
