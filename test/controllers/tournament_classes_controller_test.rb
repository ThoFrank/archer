require "test_helper"

class TournamentClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = tournaments(:indoor)
    @tournament_class = tournament_classes(:rec_herren)
    @user = users(:one)
  end

  test "should get index" do
    get tournament_tournament_classes_url(@tournament)
    assert_response :success
  end

  test "should get new" do
    authenticate_as(@user)
    get new_tournament_tournament_class_url(@tournament)
    assert_response :success
  end

  test "should create tournament_class" do
    authenticate_as(@user)
    assert_difference("TournamentClass.count") do
      post tournament_tournament_classes_url(@tournament), params: { tournament_class: {name: "Recurve Master M"} }
    end

    assert_redirected_to tournament_tournament_class_url(@tournament, TournamentClass.last)
  end

  test "should show tournament_class" do
    get tournament_tournament_class_url(@tournament, @tournament_class)
    assert_response :success
  end

  test "should get edit" do
    authenticate_as(@user)
    get edit_tournament_tournament_class_url(@tournament, @tournament_class)
    assert_response :success
  end

  test "should update tournament_class" do
    authenticate_as(@user)
    patch tournament_tournament_class_url(@tournament, @tournament_class), params: { tournament_class: {name: "Rec Herren"} }
    assert_redirected_to tournament_tournament_class_url(@tournament, @tournament_class)
  end

  test "should destroy tournament_class" do
    authenticate_as(@user)
    assert_difference("TournamentClass.count", -1) do
      delete tournament_tournament_class_url(@tournament, @tournament_class)
    end

    assert_redirected_to tournament_tournament_classes_url(@tournament)
  end
end
