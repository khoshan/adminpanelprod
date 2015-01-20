require 'test_helper'

class ExportdataControllerTest < ActionController::TestCase
  test "should get exportxlsx" do
    get :exportxlsx
    assert_response :success
  end

end
