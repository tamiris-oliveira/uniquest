class AddApprovalStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :approval_status, :integer, default: 0, null: false
    add_column :users, :approved_by, :bigint, null: true
    add_column :users, :approved_at, :datetime, null: true
    
    # Adicionar índices para performance
    add_index :users, :approval_status
    add_index :users, :approved_by
    
    # Adicionar foreign key para approved_by
    add_foreign_key :users, :users, column: :approved_by, name: 'fk_users_approved_by'
  end
end
