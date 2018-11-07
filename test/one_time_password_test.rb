require "test_helper"

class OtpTest < MiniTest::Unit::TestCase
  def setup
    @user = User.new
    @user.email = 'roberto@heapsource.com'
    @user.run_callbacks :create

    @visitor = Visitor.new
    @visitor.email = 'roberto@heapsource.com'
    @visitor.run_callbacks :create

    @member = Member.new
    @member.email = nil
    @member.run_callbacks :create

    @ar_user = ActiverecordUser.new
    @ar_user.email = 'roberto@heapsource.com'
    @ar_user.run_callbacks :create
  end

  def test_authenticate_with_otp
    code = @user.otp_code
    assert @user.authenticate_otp(code)

    code = @visitor.otp_code
    assert @visitor.authenticate_otp(code)
  end

  def test_counter_based_otp
    code = @member.otp_code
    assert @member.authenticate_otp(code)
    assert @member.authenticate_otp(code, auto_increment: true)
    assert !@member.authenticate_otp(code)
    @member.otp_counter -= 1
    assert @member.authenticate_otp(code)
    assert code == @member.otp_code
    assert code != @member.otp_code(auto_increment: true)
  end

  def test_counter_based_otp_active_record
    code = @ar_user.otp_code
    assert @ar_user.authenticate_otp(code)
    assert @ar_user.authenticate_otp(code, auto_increment: true)
    assert !@ar_user.authenticate_otp(code)
    @ar_user.otp_counter -= 1
    assert @ar_user.authenticate_otp(code)
    assert code == @ar_user.otp_code
    assert code != @ar_user.otp_code(auto_increment: true)
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
    assert_match(/^\d{4}$/, @visitor.otp_code(2160).to_s)
    assert_operator(@visitor.otp_code(2160).to_s.length, :<=, 4)
  end

  def test_otp_code_without_specific_length
    assert_match(/^\d{6}$/, @user.otp_code(2160).to_s)
    assert_operator(@user.otp_code(2160).to_s.length, :<=, 6)
  end

  def test_provisioning_uri_with_provided_account
    assert_match %r{^otpauth://totp/roberto\?secret=\w{32}$}, @user.provisioning_uri("roberto")
    assert_match %r{^otpauth://totp/roberto\?secret=\w{32}$}, @visitor.provisioning_uri("roberto")
    assert_match %r{^otpauth://hotp/roberto\?secret=\w{32}&counter=0$}, @member.provisioning_uri("roberto")
  end

  def test_provisioning_uri_with_email_field
    assert_match %r{^otpauth://totp/roberto@heapsource\.com\?secret=\w{32}$}, @user.provisioning_uri
    assert_match %r{^otpauth://totp/roberto@heapsource\.com\?secret=\w{32}$}, @visitor.provisioning_uri
    assert_match %r{^otpauth://hotp/\?secret=\w{32}&counter=0$}, @member.provisioning_uri
  end

  def test_provisioning_uri_with_options
    assert_match %r{^otpauth://totp/Example\:roberto@heapsource\.com\?secret=\w{32}&issuer=Example$}, @user.provisioning_uri(nil, issuer: "Example")
    assert_match %r{^otpauth://totp/Example\:roberto@heapsource\.com\?secret=\w{32}&issuer=Example$}, @visitor.provisioning_uri(nil, issuer: "Example")
    assert_match %r{^otpauth://totp/Example\:roberto\?secret=\w{32}&issuer=Example$}, @user.provisioning_uri("roberto", issuer: "Example")
    assert_match %r{^otpauth://totp/Example\:roberto\?secret=\w{32}&issuer=Example$}, @visitor.provisioning_uri("roberto", issuer: "Example")
  end

  def test_regenerate_otp
    secret = @user.otp_column
    @user.otp_regenerate_secret
    assert secret != @user.otp_column
  end

  def test_hide_secret_key_in_serialize
    refute_match(/otp_secret_key/, @user.to_json)
    refute_match(/otp_secret_key/, @user.to_xml)
  end
end
