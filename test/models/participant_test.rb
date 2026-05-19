require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  test "allows duplicate participants when tournament option is disabled" do
    duplicate = duplicate_of_participants_one

    assert duplicate.valid?
  end

  test "disallows duplicate participants by name birthday and club when enabled" do
    duplicate = duplicate_of_participants_one
    duplicate.Tournament.update!(disallow_duplicate_participants: true)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:base], "Participant is already registered for this tournament"
  end

  test "does not compare participants across tournaments" do
    tournament = tournaments(:vm_feld)
    tournament.update!(
      disallow_duplicate_participants: true,
      enforce_club: true,
      season_start_date: tournaments(:indoor).season_start_date,
      date_start: tournaments(:indoor).date_start,
      date_end: tournaments(:indoor).date_end
    )

    duplicate = duplicate_of_participants_one
    duplicate.Tournament = tournament
    duplicate.registration.tournament = tournament

    assert duplicate.valid?
  end

  test "existing participant remains valid when duplicate checking is enabled" do
    participant = participants(:one)
    participant.Tournament.update!(disallow_duplicate_participants: true)

    assert participant.valid?
  end

  private
    def duplicate_of_participants_one
      original = participants(:one)

      Participant.new(
        first_name: original.first_name,
        last_name: original.last_name,
        club: original.club,
        dob: original.dob,
        Tournament: original.Tournament,
        tournament_class: original.tournament_class,
        target_face: original.target_face,
        group: original.group,
        registration: Registration.new(tournament: original.Tournament, email: "duplicate@example.com")
      )
    end
end
