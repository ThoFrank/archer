class DeleteArticlesAndComments < ActiveRecord::Migration[8.0]
  def change
    drop_table :articles
    drop_table :comments
  end
end
