require "application_system_test_case"

class TargetFacesTest < ApplicationSystemTestCase
  setup do
    @tournament = tournaments(:indoor)
    @target_face = target_faces(:spot)
  end

  test "visiting the index" do
    visit tournament_target_faces_url(@tournament)
    assert_selector "h1", text: "Target faces"
  end

  test "should create target face" do
    visit tournament_target_faces_url(@tournament)
    click_on "New target face"

    click_on "Create Target face"

    assert_text "Target face was successfully created"
    click_on "Back"
  end

  test "should update Target face" do
    visit tournament_target_face_url(@tournament, @target_face)
    click_on "Edit this target face", match: :first

    click_on "Update Target face"

    assert_text "Target face was successfully updated"
    click_on "Back"
  end

  test "should destroy Target face" do
    visit tournament_target_face_url(@tournament, @target_face)
    click_on "Destroy this target face", match: :first

    assert_text "Target face was successfully destroyed"
  end
end
