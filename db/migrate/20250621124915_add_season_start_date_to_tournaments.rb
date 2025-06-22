class AddSeasonStartDateToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :season_start_date, :date
  end
end
