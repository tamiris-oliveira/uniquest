class AddSubjectIdToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_reference :questions, :subject, null: false, foreign_key: true
  end
end
