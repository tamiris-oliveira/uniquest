class RemoveUsersIdFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :users_id, :bigint
  end
end
