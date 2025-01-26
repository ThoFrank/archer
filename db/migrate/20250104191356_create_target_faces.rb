class CreateTargetFaces < ActiveRecord::Migration[8.0]
  def change
    create_table :target_faces do |t|
      t.string :name
      t.integer :distance
      t.integer :size
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end
  end
end
