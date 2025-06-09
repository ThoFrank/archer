require "application_system_test_case"

class TournamentClassesTest < ApplicationSystemTestCase
  setup do
    @tournament = tournaments(:indoor)
    @tournament_class = tournament_tournament_classes(:rec_herren)
  end

  test "visiting the index" do
    visit tournament_tournament_classes_url(@tournament)
    assert_selector "h1", text: "Tournament classes"
  end

  test "should create tournament class" do
    visit tournament_classes_url
    click_on "New tournament class"

    click_on "Create Tournament class"

    assert_text "Tournament class was successfully created"
    click_on "Back"
  end

  test "should update Tournament class" do
    visit tournament_tournament_class_url(@tournament, @tournament_class)
    click_on "Edit this tournament class", match: :first

    click_on "Update Tournament class"

    assert_text "Tournament class was successfully updated"
    click_on "Back"
  end

  test "should destroy Tournament class" do
    visit tournament_tournament_class_url(@tournament, @tournament_class)
    click_on "Destroy this tournament class", match: :first

    assert_text "Tournament class was successfully destroyed"
  end
end
