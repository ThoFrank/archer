require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "provider failures show a recovery page without requiring authentication" do
    assert_no_difference "Session.count" do
      get auth_failure_url, params: { message: "Not Found", strategy: "Nextcloud" }
    end

    assert_response :unauthorized
    assert_select "h1", "Sign-in failed"
    assert_select "a[href=?]", new_session_path, text: "Back to sign in"
  end

  test "provider failures do not display untrusted error parameters" do
    get auth_failure_url, params: { message: "untrusted error text", strategy: "untrusted provider" }

    assert_response :unauthorized
    assert_not_includes response.body, "untrusted error text"
    assert_not_includes response.body, "untrusted provider"
  end

  test "sign in sets a cookie that expires in seven days" do
    freeze_time do
      assert_difference "Session.count", 1 do
        post session_url, params: { email_address: users(:one).email_address, password: "password" }
      end

      assert_redirected_to root_url
      cookie = Array(response.headers["Set-Cookie"]).find { |value| value.start_with?("session_id=") }
      assert_includes cookie, "expires=#{7.days.from_now.httpdate}"
      assert_includes cookie, "httponly"
      assert_includes cookie, "samesite=lax"
    end
  end

  test "an existing session works just before seven days" do
    freeze_time
    authenticate_as users(:one)

    travel 7.days - 1.second
    get new_tournament_url
    assert_response :success
  end

  test "an existing session expires after seven days even if used recently" do
    freeze_time
    authenticate_as users(:one)

    travel 6.days
    get new_tournament_url
    assert_response :success

    travel 1.day
    get new_tournament_url
    assert_redirected_to new_session_url

    travel 1.day
    get new_tournament_url
    assert_redirected_to new_session_url
  end
end
