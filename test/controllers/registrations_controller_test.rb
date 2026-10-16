require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @tournament = tournaments(:indoor)
    @registration = registrations(:one)
    @participant_params = {
      first_name: "New", last_name: "Archer", club: "Club", dob: "2000-01-01",
      group: groups(:morning).id,
      tournament_class: tournament_classes(:rec_herren).id,
      target_face: target_faces(:spot).id
    }
  end

  test "single registration queues confirmation without sending in the request" do
    assert_no_difference("ActionMailer::Base.deliveries.size") do
      assert_enqueued_emails 1 do
        post tournament_registrations_url(@tournament), params: {
          participant: @participant_params, registration: { email: "new@example.com" }
        }
      end
    end
    assert_redirected_to tournament_participants_url(@tournament)
    registration = Registration.find_by!(email: "new@example.com")
    assert_enqueued_email_with ParticipantMailer, :registration_confirmation, args: [ registration ]
  end

  test "multiple registration queues one confirmation" do
    assert_no_difference("ActionMailer::Base.deliveries.size") do
      assert_enqueued_emails 1 do
        post multiple_create_tournament_registrations_url(@tournament), params: {
          participants: [ @participant_params, @participant_params.merge(first_name: "Second") ],
          registration: { email: "group@example.com" }
        }
      end
    end
    assert_redirected_to tournament_participants_url(@tournament)
    registration = Registration.find_by!(email: "group@example.com")
    assert_equal 2, registration.participants.count
    assert_enqueued_email_with ParticipantMailer, :registration_confirmation, args: [ registration ]
  end

  test "updates queue mail unless suppressed" do
    authenticate_as(users(:one))
    params = {
      participants: [ @participant_params.merge(id: participants(:thomas).id) ],
      registration: { email: @registration.email }
    }
    assert_no_difference("ActionMailer::Base.deliveries.size") do
      assert_enqueued_email_with ParticipantMailer, :registration_changed, args: [ @registration ] do
        patch tournament_registration_url(@tournament, @registration), params: params
      end
    end
    assert_response :redirect

    assert_no_enqueued_emails do
      patch tournament_registration_url(@tournament, @registration), params: params.merge(no_mail: "true")
    end
    assert_response :redirect
  end

  test "cancellation is delivered after the registration and participants are deleted" do
    authenticate_as(users(:one))
    participant_id = participants(:thomas).id
    assert_no_difference("ActionMailer::Base.deliveries.size") do
      assert_enqueued_emails 1 do
        delete tournament_registration_url(@tournament, @registration, locale: :en)
      end
    end
    assert_not Registration.exists?(@registration.id)
    assert_not Participant.exists?(participant_id)

    assert_emails 1 do
      perform_enqueued_jobs
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "one@example.com" ], mail.to
    assert_includes mail.body.decoded, "Hello Thomas,"
    assert_includes mail.body.decoded, @tournament.name
    assert_includes mail.body.decoded, "Your registration has been canceled."
  end
end
