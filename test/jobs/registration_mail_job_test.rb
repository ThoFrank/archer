require "test_helper"

class RegistrationMailJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @original = participants(:one)
    @registration = Registration.create!(tournament: @original.Tournament, email: "new@example.com")
  end

  test "removes only later duplicates before sending mail and preserves both groups" do
    duplicate = add_participant
    other = add_participant(first_name: "Other")
    original_registration = @original.registration
    original_ids = original_registration.participant_ids

    I18n.with_locale(:en) do
      RegistrationMailJob.perform_later(@registration, :registration_confirmation)
      assert Participant.exists?(duplicate.id), "removal must happen in the background"
      assert_emails 1 do
        perform_enqueued_jobs
      end
    end

    assert_not Participant.exists?(duplicate.id)
    assert_equal original_ids.sort, original_registration.reload.participant_ids.sort
    assert_equal [ other.id ], @registration.reload.participant_ids
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "new@example.com" ], mail.to
    assert_includes mail.body.decoded, "The following entries were removed"
    assert_includes mail.body.decoded, "First from common Registration"
    assert_includes mail.body.decoded, "Name: Other from common Registration"
  end

  test "duplicate-only registration delivers explanation even when no participants remain" do
    add_participant

    I18n.with_locale(:de) do
      assert_emails 1 do
        perform_enqueued_jobs do
          RegistrationMailJob.perform_later(@registration, :registration_confirmation)
        end
      end
    end

    assert_empty @registration.reload.participants
    assert Participant.exists?(@original.id)
    mail = ActionMailer::Base.deliveries.last
    assert_includes mail.body.decoded, "Die folgenden Einträge wurden entfernt"
    assert_includes mail.body.decoded, "First from common Registration"
    assert_includes mail.body.decoded, "keine Teilnehmenden mehr enthalten"
  end

  test "disabled option keeps duplicates and sends normal confirmation" do
    @registration.tournament.update!(prevent_duplicate_registrations: false)
    duplicate = add_participant

    assert_emails 1 do
      perform_enqueued_jobs do
        RegistrationMailJob.perform_later(@registration, :registration_confirmation)
      end
    end

    assert_equal [ duplicate.id ], @registration.reload.participant_ids
    assert_not_includes ActionMailer::Base.deliveries.last.body.decoded, "entries were removed"
  end

  test "merged registration keeps original participants and reports duplicate in change email" do
    @registration.update!(email: @original.registration.email)
    duplicate = add_participant
    other = add_participant(first_name: "Other")
    combined = @registration.combine_with_existing!

    assert_emails 1 do
      perform_enqueued_jobs do
        RegistrationMailJob.perform_later(combined, :registration_changed)
      end
    end

    assert_not Participant.exists?(duplicate.id)
    assert Participant.exists?(@original.id)
    assert_includes combined.reload.participant_ids, other.id
    assert_includes ActionMailer::Base.deliveries.last.body.decoded, "entries were removed"
  end

  test "mail delivery retries retain the removed participant snapshot" do
    add_participant
    RegistrationMailJob.perform_now(@registration, :registration_confirmation)
    # The queued delivery has the removal data even though the participant is gone.
    delivery = enqueued_jobs.find { |job| job[:job] == MailDeliveryJob }
    2.times do
      ActiveJob::Base.execute(delivery)
      assert_includes ActionMailer::Base.deliveries.last.body.decoded, "First from common Registration"
      assert_includes ActionMailer::Base.deliveries.last.body.decoded, "entries were removed"
    end
  end

  test "later jobs do not repeat earlier removal explanations" do
    add_participant
    RegistrationMailJob.perform_now(@registration, :registration_confirmation)
    clear_enqueued_jobs

    I18n.with_locale(:en) do
      perform_enqueued_jobs { RegistrationMailJob.perform_now(@registration, :registration_changed) }
    end
    assert_not_includes ActionMailer::Base.deliveries.last.body.decoded, "entries were removed"
  end

  private
    def add_participant(**attributes)
      participant = @original.dup
      participant.assign_attributes(attributes)
      participant.registration = @registration
      participant.save!
      participant
    end
end
