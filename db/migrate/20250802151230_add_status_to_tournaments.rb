class AddStatusToTournaments < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :status, :string
  end
end
