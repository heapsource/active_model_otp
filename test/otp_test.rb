require "test_helper"

class OtpTest < MiniTest::Unit::TestCase
  def setup
    @user = User.new
    @user.email = 'guille@firebase.co'
    @user.run_callbacks :create
  end

  def test_callback_user
    refute_nil @user.otp_secret_key
  end

  def test_authenticate_user
    assert !@user.authenticate_otp("wrong")
    assert @user.authenticate_otp(@user.otp_code)
  end

  def test_authenticate_with_drift
    code = @user.otp_code(Time.now - 30)
    assert @user.authenticate_otp(code, drift: 60)
  end

  def test_otp_code
     assert_match(/\d{6}/, @user.otp_code.to_s)
  end

  def test_provisioning_uri
    assert_match %r{otpauth://totp/guille\?secret=\w{16}}, @user.provisioning_uri("guille")
  end

  def test_provisioning_uri_with_email_field
    assert_match %r{otpauth://totp/guille@firebase\.co\?secret=\w{16}}, @user.provisioning_uri
  end
end
