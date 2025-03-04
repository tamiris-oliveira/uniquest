class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.text :statement
      t.string :question_type
      t.text :justification
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
