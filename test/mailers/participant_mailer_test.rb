require "test_helper"

class ParticipantMailerTest < ActionMailer::TestCase
  test "registration messages belong to one thread" do
    registration = registrations(:one)
    confirmation = ParticipantMailer.registration_confirmation(registration)
    change = ParticipantMailer.registration_changed(registration)
    cancellation = ParticipantMailer.registration_cancelation(
      registration_id: registration.id, email: registration.email, first_name: "Thomas",
      tournament_name: registration.tournament.name, tournament_date: registration.tournament.date_start.to_date
    )

    thread_id = "archer-registration-#{registration.id}@example.com"
    assert_equal thread_id, confirmation.message_id
    [ change, cancellation ].each do |mail|
      mail.encoded
      assert_equal thread_id, mail.in_reply_to
      assert_equal thread_id, mail.references
      assert_equal confirmation.subject, mail.subject
      refute_equal confirmation.message_id, mail.message_id
    end
    refute_equal change.message_id, cancellation.message_id
  end

  test "queued cancellation snapshots without a registration ID still deliver" do
    assert_emails 1 do
      ParticipantMailer.registration_cancelation(
        email: "one@example.com", first_name: "Thomas",
        tournament_name: "Indoor", tournament_date: Date.new(2026, 10, 16)
      ).deliver_later
      perform_enqueued_jobs
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "one@example.com" ], mail.to
    assert_nil mail.in_reply_to
    assert_nil mail.references
  end

  test "cancellation snapshot supports a group salutation in German" do
    I18n.with_locale(:de) do
      mail = ParticipantMailer.registration_cancelation(
        registration_id: registrations(:one).id, email: "group@example.com", first_name: nil,
        tournament_name: "Indoor", tournament_date: Date.new(2026, 10, 16)
      )
      assert_equal [ "group@example.com" ], mail.to
      assert_includes mail.body.decoded, "Hallo!"
      assert_includes mail.body.decoded, "Indoor"
      assert_includes mail.body.decoded, "16.10.2026"
    end
  end
end
