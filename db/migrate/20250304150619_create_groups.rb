class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :invite_code
      t.references :users, null: false, foreign_key: true

      t.timestamps
    end
  end
end
