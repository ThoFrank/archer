class AddPlaceToTournament < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :place, :string
  end
end
