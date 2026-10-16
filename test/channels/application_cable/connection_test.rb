require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  setup do
    freeze_time
    session = users(:one).sessions.create!
    cookies.signed[:session_id] = session.id
  end

  test "accepts a session just before seven days" do
    travel 7.days - 1.second

    connect

    assert_equal users(:one), connection.current_user
  end

  test "rejects a session at seven days" do
    travel 7.days

    assert_reject_connection { connect }
  end

  test "rejects a session older than seven days" do
    travel 8.days

    assert_reject_connection { connect }
  end
end
