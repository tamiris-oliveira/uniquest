class CreateGroupSimulations < ActiveRecord::Migration[8.0]
  def change
    create_table :group_simulations do |t|
      t.references :group, null: false, foreign_key: true
      t.references :simulation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
