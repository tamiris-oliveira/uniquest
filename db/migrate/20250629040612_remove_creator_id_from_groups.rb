class RemoveCreatorIdFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :creator_id, :integer
  end
end
