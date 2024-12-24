class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.string :first_name
      t.string :last_name
      t.belongs_to :Tournament

      t.timestamps
    end
  end
end
