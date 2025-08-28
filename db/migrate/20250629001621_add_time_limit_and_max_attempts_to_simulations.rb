class AddTimeLimitAndMaxAttemptsToSimulations < ActiveRecord::Migration[8.0]
  def change
    add_column :simulations, :time_limit, :integer
    add_column :simulations, :max_attempts, :integer
  end
end
