class AddMailTextToTournament < ActiveRecord::Migration[8.0]
  def change
    add_column :tournaments, :mail_text, :text
  end
end
