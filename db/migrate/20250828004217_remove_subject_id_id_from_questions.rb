class RemoveSubjectIdIdFromQuestions < ActiveRecord::Migration[8.0]
  def change
    remove_column :questions, :subject_id_id, :bigint if column_exists?(:questions, :subject_id_id)
  end
end
