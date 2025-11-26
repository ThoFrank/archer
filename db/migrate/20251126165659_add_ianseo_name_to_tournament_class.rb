class AddIanseoNameToTournamentClass < ActiveRecord::Migration[8.1]
  def change
    add_column :tournament_classes, :ianseo_name, :string
    add_column :tournament_classes, :ianseo_division, :string
  end
end
