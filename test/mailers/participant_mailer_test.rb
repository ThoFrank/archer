require "test_helper"

class ParticipantMailerTest < ActionMailer::TestCase
  test "cancellation snapshot supports a group salutation in German" do
    I18n.with_locale(:de) do
      mail = ParticipantMailer.registration_cancelation(
        email: "group@example.com", first_name: nil,
        tournament_name: "Indoor", tournament_date: Date.new(2026, 10, 16)
      )
      assert_equal [ "group@example.com" ], mail.to
      assert_includes mail.body.decoded, "Hallo!"
      assert_includes mail.body.decoded, "Indoor"
      assert_includes mail.body.decoded, "16.10.2026"
    end
  end
end
