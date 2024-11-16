class AddDateToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :date_start, :datetime
    add_column :tournaments, :date_end, :datetime
  end
end
