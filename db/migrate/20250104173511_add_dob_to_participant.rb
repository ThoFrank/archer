class AddDobToParticipant < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :dob, :date
  end
end
