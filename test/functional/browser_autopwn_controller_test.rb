require 'test_helper'

class BrowserAutopwnControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should get autopwn index" do
    get :index
    assert_response :success
  end
end
