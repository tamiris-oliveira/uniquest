class CreateSimulations < ActiveRecord::Migration[8.0]
  def change
    create_table :simulations do |t|
      t.string :title
      t.text :description
      t.datetime :creation_date
      t.date :deadline
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
