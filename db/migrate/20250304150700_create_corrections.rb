class CreateCorrections < ActiveRecord::Migration[8.0]
  def change
    create_table :corrections do |t|
      t.references :answer, null: false, foreign_key: true
      t.decimal :grade
      t.text :feedback
      t.datetime :correction_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
