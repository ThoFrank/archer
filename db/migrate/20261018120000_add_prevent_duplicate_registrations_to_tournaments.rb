class AddPreventDuplicateRegistrationsToTournaments < ActiveRecord::Migration[8.1]
  def change
    add_column :Tournaments, :prevent_duplicate_registrations, :boolean, default: true, null: false
  end
end
