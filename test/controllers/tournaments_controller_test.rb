require "test_helper"

class TournamentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tournaments_url
    assert_response :success
  end

  test "organizer can disable and enable duplicate prevention" do
    authenticate_as(users(:one))
    tournament = tournaments(:indoor)
    get edit_tournament_url(tournament)
    assert_response :success
    assert_select 'input[type="checkbox"][name="tournament[prevent_duplicate_registrations]"][checked]'

    [ false, true ].each do |enabled|
      patch tournament_url(tournament), params: { tournament: { prevent_duplicate_registrations: enabled ? "1" : "0" } }
      assert_redirected_to tournament_url(tournament)
      assert_equal enabled, tournament.reload.prevent_duplicate_registrations?
    end
  end
end
