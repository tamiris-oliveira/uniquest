class ChangeDeadlineToDatetimeInSimulations < ActiveRecord::Migration[6.1]
  def change
    change_column :simulations, :deadline, :datetime
  end
end
