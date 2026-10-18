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
      assert_enqueued_jobs 1, only: RegistrationMailJob do
        post tournament_registrations_url(@tournament), params: {
          participant: @participant_params, registration: { email: "new@example.com" }
        }
      end
    end
    assert_redirected_to tournament_participants_url(@tournament)
    registration = Registration.find_by!(email: "new@example.com")
    assert_enqueued_with job: RegistrationMailJob, args: [ registration, :registration_confirmation ]
  end

  test "multiple registration queues one confirmation" do
    assert_no_difference("ActionMailer::Base.deliveries.size") do
      assert_enqueued_jobs 1, only: RegistrationMailJob do
        post multiple_create_tournament_registrations_url(@tournament), params: {
          participants: [ @participant_params, @participant_params.merge(first_name: "Second") ],
          registration: { email: "group@example.com" }
        }
      end
    end
    assert_redirected_to tournament_participants_url(@tournament)
    registration = Registration.find_by!(email: "group@example.com")
    assert_equal 2, registration.participants.count
    assert_enqueued_with job: RegistrationMailJob, args: [ registration, :registration_confirmation ]
  end

  test "successive single and group signups combine before their queued emails run" do
    email = "combined@example.com"
    post tournament_registrations_url(@tournament), params: {
      participant: @participant_params,
      registration: { email: email, comment: "First comment" }
    }
    registration = Registration.find_by!(email: email)

    assert_no_difference("Registration.count") do
      assert_difference("Participant.count", 2) do
        assert_enqueued_with job: RegistrationMailJob, args: [ registration, :registration_changed ] do
          post multiple_create_tournament_registrations_url(@tournament), params: {
            participants: [ @participant_params.merge(first_name: "Second"), @participant_params.merge(first_name: "Third") ],
            registration: { email: email, comment: "Second comment" }
          }
        end
      end
    end
    assert_redirected_to tournament_participants_url(@tournament)
    assert_equal 3, registration.reload.participants.count
    assert_equal "First comment\nSecond comment", registration.comment

    assert_no_difference("Registration.count") do
      assert_enqueued_with job: RegistrationMailJob, args: [ registration, :registration_changed ] do
        post tournament_registrations_url(@tournament), params: {
          participant: @participant_params.merge(first_name: "Fourth"), registration: { email: email }
        }
      end
    end
    assert_equal 4, registration.reload.participants.count
    assert_emails 3 do
      perform_enqueued_jobs
    end
    assert_includes ActionMailer::Base.deliveries.last.body.decoded, "Fourth"
  end

  test "invalid group signup rolls back participants and registration" do
    assert_no_difference([ "Registration.count", "Participant.count" ]) do
      assert_no_enqueued_jobs do
        post multiple_create_tournament_registrations_url(@tournament), params: {
          participants: [ @participant_params, @participant_params.merge(first_name: "") ],
          registration: { email: "invalid@example.com" }
        }
      end
    end
    assert_response :unprocessable_content
  end

  test "updates queue mail unless suppressed" do
    authenticate_as(users(:one))
    params = {
      participants: [ @participant_params.merge(id: participants(:thomas).id) ],
      registration: { email: @registration.email }
    }
    assert_no_difference("ActionMailer::Base.deliveries.size") do
      assert_enqueued_with job: RegistrationMailJob, args: [ @registration, :registration_changed ] do
        patch tournament_registration_url(@tournament, @registration), params: params
      end
    end
    assert_response :redirect

    assert_enqueued_with job: RegistrationMailJob, args: [ @registration, nil ] do
      patch tournament_registration_url(@tournament, @registration), params: params.merge(no_mail: "true")
    end
    assert_response :redirect
  end

  test "updates without email still remove duplicate participants in the background" do
    authenticate_as(users(:one))
    original = participants(:one)
    @registration = Registration.create!(tournament: @tournament, email: "edit@example.com")
    participant = original.dup
    participant.first_name = "Before edit"
    participant.registration = @registration
    participant.save!
    params = {
      participants: [ @participant_params.merge(id: participant.id, first_name: original.first_name,
        last_name: original.last_name, dob: original.dob.to_s) ],
      registration: { email: @registration.email }, no_mail: "true"
    }

    assert_no_emails do
      patch tournament_registration_url(@tournament, @registration), params: params
      assert_response :redirect
      assert_equal 2, @tournament.participants.where(first_name: original.first_name,
        last_name: original.last_name, dob: original.dob).count
      perform_enqueued_jobs
    end

    assert_equal 1, @tournament.participants.where(first_name: original.first_name,
      last_name: original.last_name, dob: original.dob).count
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
