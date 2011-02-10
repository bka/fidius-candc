require 'test_helper'

class MultihandlersControllerTest < ActionController::TestCase
  include DrbHelper
  
  # Replace this with your real tests.
  test "should get multihandler index" do
    get :index
    assert_response :success
  end
  
  test "should create multihandler" do
    post :create, { :port => "7777", :interface => "0.0.0.0", :payload => "windows/x64/vncinject/bind_tcp" }
    assert_response :redirect
  end
  
  test "no interfaces at multihandler index" do
    get :index
    assert_response :success
    assert_same @interfaces, nil
  end
  
  test "no multihandlers without worker" do
    get :index
    assert_response :success
    assert_same @multihandlers, nil
  end
  
end
