require "test_helper"

class TargetFacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = tournaments(:indoor)
    @target_face = target_faces(:spot)
  end

  test "should get index" do
    get tournament_target_faces_url(@tournament)
    assert_response :success
  end

  test "should get new" do
    get new_tournament_target_face_url(@tournament)
    assert_response :success
  end

  test "should create target_face" do
    assert_difference("TargetFace.count") do
      post tournament_target_faces_url(@tournament), params: { target_face: {name: "60cm", distance: 18, size: 60 } }
    end

    assert_redirected_to tournament_target_face_url(@tournament, TargetFace.last)
  end

  test "should show target_face" do
    get tournament_target_face_url(@tournament, @target_face)
    assert_response :success
  end

  test "should get edit" do
    get edit_tournament_target_face_url(@tournament, @target_face)
    assert_response :success
  end

  test "should update target_face" do
    patch tournament_target_face_url(@tournament, @target_face), params: { target_face: {distance: 25} }
    assert_redirected_to tournament_target_face_url(@tournament, @target_face)
  end

  test "should destroy target_face" do
    assert_difference("TargetFace.count", -1) do
      delete tournament_target_face_url(@tournament, @target_face)
    end

    assert_redirected_to tournament_target_faces_url(@tournament)
  end
end
