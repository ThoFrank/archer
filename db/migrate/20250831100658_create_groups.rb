class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :participants, :group, foreign_key: true
  end
end
