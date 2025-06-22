require "test_helper"

class TournamentClassTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "from_date" do
    tournament = Tournament.new(season_start_date: Date.new(2025))
    c = TournamentClass.new(tournament: tournament, age_start: 21, age_end: 49)
    assert_equal(Date.new(1976), c.from_date)
    assert_equal(Date.new(2004, 12, 31), c.to_date)
  end
end
