class AddCourseToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :course, null: true, foreign_key: true
  end
end
