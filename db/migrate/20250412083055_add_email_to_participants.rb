class AddEmailToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :email, :string
  end
end
