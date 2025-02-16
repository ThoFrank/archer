require "test_helper"

class TournamentClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tournament_class = tournament_classes(:one)
  end

  test "should get index" do
    get tournament_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_tournament_class_url
    assert_response :success
  end

  test "should create tournament_class" do
    assert_difference("TournamentClass.count") do
      post tournament_classes_url, params: { tournament_class: {} }
    end

    assert_redirected_to tournament_class_url(TournamentClass.last)
  end

  test "should show tournament_class" do
    get tournament_class_url(@tournament_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_tournament_class_url(@tournament_class)
    assert_response :success
  end

  test "should update tournament_class" do
    patch tournament_class_url(@tournament_class), params: { tournament_class: {} }
    assert_redirected_to tournament_class_url(@tournament_class)
  end

  test "should destroy tournament_class" do
    assert_difference("TournamentClass.count", -1) do
      delete tournament_class_url(@tournament_class)
    end

    assert_redirected_to tournament_classes_url
  end
end
