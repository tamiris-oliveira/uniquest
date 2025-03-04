class CreateAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :answers do |t|
      t.text :student_answer
      t.boolean :correct
      t.references :question, null: false, foreign_key: true
      t.references :attempt, null: false, foreign_key: true

      t.timestamps
    end
  end
end
