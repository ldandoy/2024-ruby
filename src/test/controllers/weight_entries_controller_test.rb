require "test_helper"

class WeightEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get weight_entries_index_url
    assert_response :success
  end
end
