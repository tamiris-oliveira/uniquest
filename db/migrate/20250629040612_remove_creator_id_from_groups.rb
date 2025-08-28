class RemoveCreatorIdFromGroups < ActiveRecord::Migration[8.0]
  def change
    # Column already removed or doesn't exist
    # remove_column :groups, :creator_id, :integer
  end
end
