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
    assert_match(/\d{5,6}/, @user.otp_code.to_s)
    assert_match(/\d{5,6}/, @visitor.otp_code.to_s)
  end

  def test_provisioning_uri_with_provided_account
    assert_match %r{otpauth://totp/roberto\?secret=\w{16}}, @user.provisioning_uri("roberto")
    assert_match %r{otpauth://totp/roberto\?secret=\w{16}}, @visitor.provisioning_uri("roberto")
  end

  def test_provisioning_uri_with_email_field
    assert_match %r{otpauth://totp/roberto@heapsource\.com\?secret=\w{16}}, @user.provisioning_uri
    assert_match %r{otpauth://totp/roberto@heapsource\.com\?secret=\w{16}}, @visitor.provisioning_uri
  end
end
