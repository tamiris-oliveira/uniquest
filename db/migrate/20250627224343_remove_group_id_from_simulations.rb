class RemoveGroupIdFromSimulations < ActiveRecord::Migration[8.0]
  def up
    change_column :simulations, :deadline, :datetime
  end

  def down
    change_column :simulations, :deadline, :date
  end
end
