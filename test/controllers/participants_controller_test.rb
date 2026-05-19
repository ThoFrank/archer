require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = tournaments(:indoor)
    @participant = participants(:thomas)
    @registration = registrations(:one)
    @user = users(:one)
  end

  test "should get index" do
    get tournament_participants_url(@tournament)
    assert_response :success
  end

  test "should get new" do
    get new_tournament_registration_url(@tournament)
    assert_response :success
  end

  test "should create participant" do
    assert_difference("Participant.count") do
      post tournament_registrations_url(@tournament), params: {
        participant: {
          first_name: "Foo",
          last_name: "Bar",
          club: "FooClub",
          group: groups(:morning).id,
          Tournament: "indoor",
          tournament_class: tournament_classes(:rec_herren).id,
          target_face: target_faces(:spot).id,
          dob: "2000-01-01"
        },
        registration: {
          email: "foo@bar.com"
        }
      }
    end

    assert_redirected_to tournament_participants_url(@tournament)
  end

  test "rerenders single registration with submitted values and error when participant is duplicate" do
    @tournament.update!(disallow_duplicate_participants: true)
    participant = participants(:one)

    assert_no_difference("Participant.count") do
      assert_no_difference("Registration.count") do
        post tournament_registrations_url(@tournament), params: {
          participant: {
            first_name: participant.first_name,
            last_name: participant.last_name,
            club: participant.club,
            group: participant.group.id,
            tournament_class: participant.tournament_class.id,
            target_face: participant.target_face.id,
            dob: participant.dob.to_s
          },
          registration: {
            email: "duplicate@example.com",
            comment: "Please keep this"
          }
        }
      end
    end

    assert_response :unprocessable_content
    assert_includes response.body, "Participant is already registered for this tournament"
    assert_includes response.body, participant.first_name
    assert_includes response.body, participant.last_name
    assert_includes response.body, "duplicate@example.com"
    assert_includes response.body, "Please keep this"
  end

  test "rerenders multiple registration with all submitted values and error when one participant is duplicate" do
    @tournament.update!(disallow_duplicate_participants: true)
    participant = participants(:one)

    assert_no_difference("Participant.count") do
      assert_no_difference("Registration.count") do
        post tournament_multiple_create_registrations_url(@tournament), params: {
          participants: [
            {
              first_name: "Fresh",
              last_name: "Archer",
              club: "FooBar",
              group: groups(:morning).id,
              tournament_class: tournament_classes(:rec_herren).id,
              target_face: target_faces(:spot).id,
              dob: "2000-01-01"
            },
            {
              first_name: participant.first_name,
              last_name: participant.last_name,
              club: participant.club,
              group: participant.group.id,
              tournament_class: participant.tournament_class.id,
              target_face: participant.target_face.id,
              dob: participant.dob.to_s
            }
          ],
          registration: {
            email: "team-duplicate@example.com",
            comment: "Keep both rows"
          }
        }
      end
    end

    assert_response :unprocessable_content
    assert_includes response.body, "Participant is already registered for this tournament"
    assert_includes response.body, "Fresh"
    assert_includes response.body, "Archer"
    assert_includes response.body, participant.first_name
    assert_includes response.body, participant.last_name
    assert_includes response.body, "team-duplicate@example.com"
    assert_includes response.body, "Keep both rows"
  end

  test "should get edit" do
    authenticate_as(@user)
    get edit_tournament_registration_url(@tournament, @registration)
    assert_response :success
  end

  test "should update participant" do
    authenticate_as(@user)
    patch tournament_registration_url(@tournament, @registration), params: {
      participants: [ {
        id: @participant.id,
        first_name: "Foo",
        last_name: "Bar",
        club: "FooClub",
        group: groups(:morning).id,
        Tournament: "indoor",
        tournament_class: tournament_classes(:rec_herren).id,
        target_face: target_faces(:spot).id,
        dob: "2000-01-01"
      } ],
      registration: {
        email: "foo@bar.com"
      }
    }
    assert_response :found
    assert_redirected_to tournament_participants_url(@tournament)
  end

  test "should destroy participant" do
    authenticate_as(@user)
    assert_difference("Participant.count", -1) do
      delete tournament_registration_url(@tournament, @registration)
    end

    assert_redirected_to tournament_participants_url(@tournament)
  end
end
