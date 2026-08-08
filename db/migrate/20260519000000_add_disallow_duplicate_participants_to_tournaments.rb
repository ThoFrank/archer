class AddDisallowDuplicateParticipantsToTournaments < ActiveRecord::Migration[8.1]
  def change
    add_column :Tournaments, :disallow_duplicate_participants, :boolean, default: false, null: false
  end
end
