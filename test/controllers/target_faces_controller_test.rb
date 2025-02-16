require "test_helper"

class TargetFacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @target_face = target_faces(:one)
  end

  test "should get index" do
    get target_faces_url
    assert_response :success
  end

  test "should get new" do
    get new_target_face_url
    assert_response :success
  end

  test "should create target_face" do
    assert_difference("TargetFace.count") do
      post target_faces_url, params: { target_face: {} }
    end

    assert_redirected_to target_face_url(TargetFace.last)
  end

  test "should show target_face" do
    get target_face_url(@target_face)
    assert_response :success
  end

  test "should get edit" do
    get edit_target_face_url(@target_face)
    assert_response :success
  end

  test "should update target_face" do
    patch target_face_url(@target_face), params: { target_face: {} }
    assert_redirected_to target_face_url(@target_face)
  end

  test "should destroy target_face" do
    assert_difference("TargetFace.count", -1) do
      delete target_face_url(@target_face)
    end

    assert_redirected_to target_faces_url
  end
end
