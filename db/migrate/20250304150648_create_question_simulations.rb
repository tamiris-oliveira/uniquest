class CreateQuestionSimulations < ActiveRecord::Migration[8.0]
  def change
    create_table :question_simulations do |t|
      t.references :simulation, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
