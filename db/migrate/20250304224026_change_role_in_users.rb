class ChangeRoleInUsers < ActiveRecord::Migration[6.0]
  def up
    execute "ALTER TABLE users ALTER COLUMN role TYPE INTEGER USING role::INTEGER"
    change_column_default :users, :role, 0
    change_column_null :users, :role, false
  end

  def down
    change_column :users, :role, :string
  end
end
