class AddCreatorIdToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :creator_id, :integer
  end
end
