class AddClubToParticipants < ActiveRecord::Migration[8.0]
  def change
    add_column :participants, :club, :string
    add_column :tournaments, :enforce_club, :boolean
  end
end
