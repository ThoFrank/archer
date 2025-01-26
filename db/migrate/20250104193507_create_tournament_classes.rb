class CreateTournamentClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :tournament_classes do |t|
      t.string :name
      t.integer :age_start
      t.integer :age_end
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end
  end
end
