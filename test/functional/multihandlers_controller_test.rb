require 'test_helper'

class MultihandlersControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should get multihandler index" do
    get :index
    assert_response :success
  end
  
  test "should create multihandler" do
    post :create, { :port => "7777", :interface => "0.0.0.0", :payload => "windows/x64/vncinject/bind_tcp" }
    assert_response :redirect
  end
  
end
