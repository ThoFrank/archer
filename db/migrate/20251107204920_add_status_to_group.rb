class AddStatusToGroup < ActiveRecord::Migration[8.1]
  def change
    add_column :groups, :status, :string, null: false, default: "active"
  end
end
