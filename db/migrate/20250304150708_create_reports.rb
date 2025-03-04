class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true
      t.integer :correct_answers
      t.integer :incorrect_answers
      t.decimal :total_grade
      t.datetime :generation_date

      t.timestamps
    end
  end
end
