require 'test_helper'

class SendnotificationControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
