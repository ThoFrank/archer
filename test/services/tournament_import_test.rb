require "test_helper"

class TournamentImportTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  setup do
    @source = tournaments(:indoor)
    @data = JSON.parse(TournamentExport.new(@source, include_participants: true).as_json.to_json)
    @destination = Tournament.create!(name: "Destination", date_start: @source.date_start,
      date_end: @source.date_end, season_start_date: @source.season_start_date)
  end

  test "imports in dependency order and remaps all IDs without modifying source records" do
    @source.update!(description: "<p>Import description</p>", mail_text: "Welcome")
    @data = JSON.parse(TournamentExport.new(@source, include_participants: true).as_json.to_json)
    source_before = TournamentExport.new(@source, include_participants: true).as_json
    assert_no_enqueued_jobs do
      TournamentImport.new(@destination, @data, mode: "overwrite").call
    end

    assert_equal @source.name, @destination.reload.name
    assert_includes @destination.description.body.to_s, "Import description"
    assert_equal "Welcome", @destination.mail_text
    assert_equal 2, @destination.groups.count
    assert_equal 2, @destination.target_faces.count
    assert_equal 2, @destination.tournament_classes.count
    assert_equal 4, @destination.participants.count
    assert_equal 3, Registration.where(tournament: @destination).count
    @destination.tournament_classes.each do |klass|
      assert_equal @destination.target_faces.ids.sort, klass.target_face_ids.sort
    end
    @destination.participants.each do |participant|
      original = @source.participants.find_by!(first_name: participant.first_name)
      assert_not_equal original.id, participant.id
      assert_equal @destination.id, participant.tournament_class.tournament_id
      assert_equal original.tournament_class.name, participant.tournament_class.name
      assert_equal @destination.id, participant.target_face.tournament_id
      assert_equal original.target_face.name, participant.target_face.name
      if original.group
        assert_equal original.group.name, participant.group.name
        assert_equal @destination.id, participant.group.tournament_id
      else
        assert_nil participant.group
      end
      assert_equal @destination.id, participant.registration.tournament_id
      assert_equal original.registration.email, participant.registration.email
    end
    assert_equal 1, @destination.participants.where(first_name: %w[ First Second ]).map(&:registration).map(&:id).uniq.count
    assert_equal source_before, TournamentExport.new(@source.reload, include_participants: true).as_json
  end

  test "add mode preserves settings and all records with matching local IDs" do
    @data["tournament"]["name"] = "Changed"
    @data["groups"].first["name"] = "Changed group"
    @data["target_faces"].first["name"] = "Changed face"
    @data["tournament_classes"].first["name"] = "Changed class"
    @data["participants"].first["first_name"] = "Changed name"
    @data["participants"].first["registration"]["email"] = "changed@example.com"
    @data["participants"].first["registration"]["id"] = Registration.maximum(:id) + 100
    before = TournamentExport.new(@source, include_participants: true).as_json
    registration_count = Registration.count
    TournamentImport.new(@source, @data).call
    assert_equal before, TournamentExport.new(@source.reload, include_participants: true).as_json
    assert_equal registration_count, Registration.count
  end

  test "update mode updates matching records and keeps records absent from export" do
    participant = @data["participants"].first
    participant["first_name"] = "Updated"
    participant["group_id"] = @data["groups"].last["id"]
    participant["registration"]["comment"] = "Updated comment"
    @data["tournament"]["name"] = "Updated tournament"
    @data["target_faces"].first["name"] = "Updated face"
    @data["tournament_classes"].first["target_face_ids"] = [ @data["target_faces"].first["id"] ]
    extra = @source.groups.create!(name: "Not in file")
    TournamentImport.new(@source, @data, mode: "overwrite").call
    assert_equal "Updated tournament", @source.reload.name
    assert extra.reload
    record = @source.participants.find(participant["id"])
    assert_equal "Updated", record.first_name
    assert_equal participant["group_id"], record.group_id
    assert_equal "Updated comment", record.registration.comment
    assert_equal "Updated face", @source.target_faces.find(@data["target_faces"].first["id"]).name
    assert_equal @data["tournament_classes"].first["target_face_ids"], @source.tournament_classes.find(@data["tournament_classes"].first["id"]).target_face_ids
    assert_equal 4, @source.participants.count
  end

  test "newly allocated IDs do not match later source IDs" do
    next_id = [ Group.maximum(:id).to_i, ActiveRecord::Base.connection.select_value("SELECT seq FROM sqlite_sequence WHERE name = 'groups'").to_i ].max + 1
    @data["groups"] = [ { "id" => next_id + 100, "name" => "First" }, { "id" => next_id, "name" => "Second" } ]
    @data["participants"] = []
    TournamentImport.new(@destination, @data).call
    assert_equal %w[ First Second ], @destination.groups.order(:id).pluck(:name)
  end

  test "unknown references roll back settings and every created record" do
    @data["participants"].last["group_id"] = groups(:morning).id + 100
    before = [ Group.count, TargetFace.count, TournamentClass.count, Registration.count, Participant.count ]
    assert_raises(TournamentImport::Error) do
      TournamentImport.new(@destination, @data, mode: "overwrite").call
    end
    assert_equal "Destination", @destination.reload.name
    assert_equal before, [ Group.count, TargetFace.count, TournamentClass.count, Registration.count, Participant.count ]
  end

  test "references cannot fall back to records outside the imported arrays" do
    @data["target_faces"] = []
    assert_raises(TournamentImport::Error) { TournamentImport.new(@destination, @data).call }
    assert_empty @destination.groups.reload
  end

  test "configuration-only imports keep existing participants" do
    @data.delete("participants")
    TournamentImport.new(@source, @data, mode: "overwrite").call
    assert_equal 4, @source.participants.count
  end

  test "add mode links new participants and classes to matching local dependencies" do
    original_class = @data["tournament_classes"].first
    original_face_id = original_class["target_face_ids"].first
    original_participant = @data["participants"].first
    @data["tournament_classes"] << original_class.merge("id" => TournamentClass.maximum(:id) + 100, "name" => "New class")
    new_participant = original_participant.merge("id" => Participant.maximum(:id) + 100,
      "first_name" => "New participant", "tournament_class_id" => @data["tournament_classes"].last["id"], "target_face_id" => original_face_id)
    @data["participants"] << new_participant
    TournamentImport.new(@source, @data).call
    participant = @source.participants.find_by!(first_name: "New participant")
    assert_equal "New class", participant.tournament_class.name
    assert_equal original_face_id, participant.target_face_id
    assert_equal original_class["target_face_ids"].sort, participant.tournament_class.target_face_ids.sort
    assert_equal original_participant["registration"]["id"], participant.registration.id
    assert_equal 5, @source.participants.count
  end

  test "conflicting shared registrations roll back the import" do
    shared = @data["participants"].group_by { |participant| participant["registration"]["id"] }.values.find { |rows| rows.length > 1 }
    shared.last["registration"]["email"] = "conflict@example.com"
    assert_raises(TournamentImport::Error) { TournamentImport.new(@destination, @data, mode: "overwrite").call }
    assert_empty @destination.groups.reload
    assert_empty Registration.where(tournament: @destination)
  end

  test "invalid structure duplicate IDs and invalid settings are rejected" do
    [ [], {}, @data.merge("groups" => {}), @data.merge("groups" => [ @data["groups"].first ] * 2),
      @data.merge("tournament" => @data["tournament"].merge("name" => "")) ].each do |data|
      assert_raises(TournamentImport::Error) { TournamentImport.new(@destination, data, mode: "overwrite").call }
      assert_equal "Destination", @destination.reload.name
      assert_empty @destination.groups.reload
    end
  end
end
