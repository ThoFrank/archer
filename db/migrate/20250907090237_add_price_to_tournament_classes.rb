class AddPriceToTournamentClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :tournament_classes, :price, :integer
  end
end
