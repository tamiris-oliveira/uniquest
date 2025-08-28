class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.text :description
      t.string :code, null: false

      t.timestamps
    end
    
    add_index :courses, :code, unique: true
    add_index :courses, :name
  end
end
