class CreateRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :registrations do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :email

      t.timestamps
    end
  end
end
