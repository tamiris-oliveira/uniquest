class SetDefaultMaxAttemptsInSimulations < ActiveRecord::Migration[8.0]
  def change
    change_column_default :simulations, :max_attempts, from: nil, to: 1
  end
end
