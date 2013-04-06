require "test_helper"

class OtpTest < MiniTest::Unit::TestCase
  def setup
    @user = User.new
    @user.run_callbacks :create
    @visitor = Visitor.new
    @visitor.run_callbacks :create
  end

  def test_callback_user
    refute_nil @user.otp_secret_key
  end

  def test_authenticate_user
    assert !@user.authenticate_otp("wrong")
    assert @user.authenticate_otp(@user.otp_code)
  end

  def test_callback_visitor
    refute_nil @visitor.otp_token
  end

  def test_authenticate_user
    assert !@visitor.authenticate_otp("wrong")
    assert @visitor.authenticate_otp(@visitor.otp_code)
  end
end
