require "test_helper"

class TournamentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tournaments_url
    assert_response :success
  end

  test "export section is only shown to organizers with participants unchecked" do
    tournament = tournaments(:indoor)
    get tournament_url(tournament)
    assert_select "form[action=?]", export_tournament_path(tournament), count: 0

    authenticate_as(users(:one))
    [ :en, :de ].each do |locale|
      get tournament_url(tournament, locale: locale)
      assert_response :success
      assert_select "form[action=?][method=get][data-turbo=false]", export_tournament_path(tournament, locale: locale) do
        assert_select "input[type=checkbox][name=include_participants]:not([checked])", count: 1
      end
      assert_no_match "Translation missing", response.body
    end
  end

  test "export requires authentication even when participants are requested" do
    get export_tournament_url(tournaments(:indoor)), params: { include_participants: "1" }
    assert_redirected_to new_session_path
  end

  test "export includes all tournament configuration and omits participants by default" do
    authenticate_as(users(:one))
    tournament = tournaments(:indoor)
    tournament.update!(description: "<p>Tournament information</p>", mail_text: "Welcome", status: "active")
    unused_face = tournament.target_faces.create!(name: "Unused face", distance: 30, size: 80)
    other_tournament = tournaments(:vm_feld)
    other_tournament.groups.create!(name: "Other group")
    other_tournament.target_faces.create!(name: "Other face")
    other_tournament.tournament_classes.create!(name: "Other class")

    [ nil, "0" ].each do |include_participants|
      get export_tournament_url(tournament), params: { include_participants: include_participants }
      assert_response :success
      assert_equal "application/json", response.media_type
      assert_match 'attachment; filename="15-indoor.json"', response.headers["Content-Disposition"]
      json = JSON.parse(response.body)
      settings = json.fetch("tournament")
      %w[ name place date_start date_end season_start_date status enforce_club prevent_duplicate_registrations mail_text ].each do |field|
        assert_equal tournament.as_json[field], settings[field], field
      end
      assert_includes settings.fetch("description"), "<p>Tournament information</p>"
      assert_equal tournament.groups.order(:id).as_json(only: %i[ id name status ]), json.fetch("groups")
      assert_equal tournament.target_faces.order(:id).as_json(only: %i[ id name distance size ]), json.fetch("target_faces")
      assert_includes json.fetch("target_faces").map { |face| face["id"] }, unused_face.id
      assert_equal tournament.tournament_classes.order(:id).ids, json.fetch("tournament_classes").map { |klass| klass["id"] }
      klass = json.fetch("tournament_classes").find { |entry| entry["id"] == tournament_classes(:rec_herren).id }
      assert_equal tournament_classes(:rec_herren).target_face_ids.sort, klass.fetch("target_face_ids").sort
      assert_equal tournament_classes(:rec_herren).age_start, klass.fetch("age_start")
      assert_not json.key?("participants")
      assert_not_includes response.body, registrations(:one).email
    end
  end

  test "export optionally includes participants with references and registration details" do
    authenticate_as(users(:one))
    tournament = tournaments(:indoor)
    registrations(:three).update!(comment: "Registration comment")
    outsider = participants(:thomas).dup
    outsider.Tournament = tournaments(:vm_feld)
    outsider.save!(validate: false)

    get export_tournament_url(tournament), params: { include_participants: "1" }
    assert_response :success
    json = JSON.parse(response.body)
    exported = json.fetch("participants")
    assert_equal tournament.participants.order(:id).ids, exported.map { |participant| participant["id"] }
    participant = participants(:one)
    entry = exported.find { |record| record["id"] == participant.id }
    %w[ first_name last_name dob club group_id tournament_class_id target_face_id ].each do |field|
      assert_equal participant.as_json[field], entry[field], field
    end
    assert_equal participant.registration.as_json(only: %i[ id email comment ]), entry.fetch("registration")
    assert_equal "Registration comment", entry.fetch("registration").fetch("comment")
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
