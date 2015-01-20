require 'test_helper'

class SendemailControllerTest < ActionController::TestCase
  test "should get with" do
    get :with
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
