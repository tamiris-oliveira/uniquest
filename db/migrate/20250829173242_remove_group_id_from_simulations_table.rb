class RemoveGroupIdFromSimulationsTable < ActiveRecord::Migration[8.0]
  def change
    remove_column :simulations, :group_id, :bigint
  end
end
