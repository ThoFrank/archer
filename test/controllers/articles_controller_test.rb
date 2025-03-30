require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    authenticate_as(users(:one))
    get articles_url
    assert_response :success
  end
end
