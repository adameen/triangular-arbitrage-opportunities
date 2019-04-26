require 'test_helper'

class RealtimeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get realtime_index_url
    assert_response :success
  end

end
