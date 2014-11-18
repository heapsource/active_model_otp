require "test_helper"

class OtpTest < MiniTest::Unit::TestCase
  def setup
    @user = User.new
    @user.email = 'roberto@heapsource.com'
    @user.run_callbacks :create

    @visitor = Visitor.new
    @visitor.email = 'roberto@heapsource.com'
    @visitor.run_callbacks :create
  end

  def test_authenticate_with_otp
    code = @user.otp_code

    assert @user.authenticate_otp(code)

    code = @visitor.otp_code
    assert @visitor.authenticate_otp(code)
  end

  def test_authenticate_with_otp_when_drift_is_allowed
    code = @user.otp_code(Time.now - 30)
    assert @user.authenticate_otp(code, drift: 60)

    code = @visitor.otp_code(Time.now - 30)
    assert @visitor.authenticate_otp(code, drift: 60)
  end

  def test_otp_code
    assert_match(/^\d{6}$/, @user.otp_code.to_s)
    assert_match(/^\d{4}$/, @visitor.otp_code.to_s)
  end

  def test_otp_code_with_specific_length
    assert_match(/^\d{4}$/, @visitor.otp_code(time: 2160, padding: true).to_s)
    assert_operator(@visitor.otp_code(time: 2160, padding: false).to_s.length, :<= , 4)
  end

  def test_otp_code_without_specific_length
   assert_match(/^\d{6}$/, @user.otp_code(time: 2160, padding: true).to_s)
   assert_operator(@user.otp_code(time: 2160, padding: false).to_s.length, :<= , 6)
  end

  def test_otp_code_padding
    @user.otp_column = 'kw5jhligwqaiw7jc'
    assert_match(/^\d{6}$/, @user.otp_code(time: 2160, padding: true).to_s)
    # Modified this spec as it is not guranteed that without padding we will always
    # get a 3 digit number
    assert_operator(@user.otp_code(time: 2160, padding: false).to_s.length, :<= , 6)
  end

  def test_provisioning_uri_with_provided_account
    assert_match %r{otpauth://totp/roberto\?secret=\w{16}}, @user.provisioning_uri("roberto")
    assert_match %r{otpauth://totp/roberto\?secret=\w{16}}, @visitor.provisioning_uri("roberto")
  end

  def test_provisioning_uri_with_email_field
    assert_match %r{otpauth://totp/roberto@heapsource\.com\?secret=\w{16}}, @user.provisioning_uri
    assert_match %r{otpauth://totp/roberto@heapsource\.com\?secret=\w{16}}, @visitor.provisioning_uri
  end

  def test_provisioning_uri_with_options
    assert_match  %r{otpauth://totp/roberto@heapsource\.com\?issuer=Example&secret=\w{16}},@user.provisioning_uri(nil,issuer: "Example")
    assert_match %r{otpauth://totp/roberto@heapsource\.com\?issuer=Example&secret=\w{16}}, @visitor.provisioning_uri(nil,issuer: "Example")
    assert_match %r{otpauth://totp/roberto\?issuer=Example&secret=\w{16}}, @user.provisioning_uri("roberto", issuer: "Example")
    assert_match %r{otpauth://totp/roberto\?issuer=Example&secret=\w{16}}, @visitor.provisioning_uri("roberto", issuer: "Example")
  end

  def test_regenerate_otp
    secret = @user.otp_column
    @user.otp_regenerate_secret
    assert secret != @user.otp_column
  end
end
