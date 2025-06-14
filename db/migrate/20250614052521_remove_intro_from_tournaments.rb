class RemoveIntroFromTournaments < ActiveRecord::Migration[8.0]
  def change
    remove_column :Tournaments, :intro, :string
  end
end
