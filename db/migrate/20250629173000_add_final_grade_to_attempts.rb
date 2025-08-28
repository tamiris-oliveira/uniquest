class AddFinalGradeToAttempts < ActiveRecord::Migration[8.0]
  def change
    add_column :attempts, :final_grade, :decimal, precision: 10, scale: 2
  end
end
