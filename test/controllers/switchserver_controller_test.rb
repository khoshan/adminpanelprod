require 'test_helper'

class SwitchserverControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
