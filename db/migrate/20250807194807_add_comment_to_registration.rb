class AddCommentToRegistration < ActiveRecord::Migration[8.0]
  def change
    add_column :registrations, :comment, :text
  end
end
