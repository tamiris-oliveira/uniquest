class ChangeDeadlineToDatetimeInSimulations < ActiveRecord::Migration[6.1]
  def up
    change_column :simulations, :deadline, :datetime
  end

  def down
    change_column :simulations, :deadline, :date
  end
end
