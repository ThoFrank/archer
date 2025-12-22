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

  test "should get edit" do
    authenticate_as(@user)
    get edit_tournament_registration_url(@tournament, @registration)
    assert_response :success
  end

  test "should update participant" do
    authenticate_as(@user)
    patch tournament_registration_url(@tournament, @registration), params: {
      participants: [ {
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
