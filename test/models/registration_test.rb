require "test_helper"

class RegistrationTest < ActiveSupport::TestCase
  setup do
    @existing = registrations(:three)
    @existing.update!(comment: "Original comment")
  end

  test "combines participants and comments into the oldest matching registration" do
    incoming = duplicate_registration(comment: "New comment")
    participant = incoming.participants.first
    original_ids = @existing.participant_ids

    assert_difference("Registration.count", -1) do
      assert_no_difference("Participant.count") do
        assert_equal @existing, incoming.combine_with_existing!
      end
    end
    assert_equal (original_ids + [ participant.id ]).sort, @existing.reload.participant_ids.sort
    assert_equal @existing, participant.reload.registration
    assert_equal "Original comment\nNew comment", @existing.comment
    assert_not Registration.exists?(incoming.id)
    assert_equal @existing, @existing.combine_with_existing!
  end

  test "ignores blank comments" do
    duplicate_registration(comment: " ").combine_with_existing!
    assert_equal "Original comment", @existing.reload.comment
  end

  test "requires matching tournament email and club" do
    [ { tournament: tournaments(:vm_feld) }, { email: "other@example.com" }, { club: "Other Club" } ].each do |attributes|
      incoming = duplicate_registration(**attributes)
      assert_no_difference("Registration.count") do
        assert_equal incoming, incoming.combine_with_existing!
      end
    end
  end

  test "does not match empty registrations or mixed club registrations" do
    empty = Registration.create!(tournament: @existing.tournament, email: @existing.email)
    assert_equal empty, empty.combine_with_existing!

    incoming = duplicate_registration
    incoming.participants << participants(:thomas)
    assert_equal incoming, incoming.combine_with_existing!

    @existing.participants.last.update_column(:club, "Other Club")
    single_club = duplicate_registration
    assert_equal single_club, single_club.combine_with_existing!
  end

  test "combines registrations without a club" do
    @existing.participants.update_all(club: nil)
    incoming = duplicate_registration(club: nil)
    assert_equal @existing, incoming.combine_with_existing!
  end

  private
    def duplicate_registration(comment: nil, tournament: @existing.tournament, email: @existing.email, club: "FooBar")
      registration = Registration.create!(tournament: tournament, email: email, comment: comment)
      participant = participants(:one).dup
      participant.club = club
      participant.save!(validate: false)
      registration.participants << participant
      registration
    end
end
