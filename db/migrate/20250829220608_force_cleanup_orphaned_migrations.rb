class ForceCleanupOrphanedMigrations < ActiveRecord::Migration[8.0]
  def up
    # Execute SQL direto para limpar migrações órfãs sem validação do Rails
    connection.execute <<-SQL
      DELETE FROM schema_migrations 
      WHERE version IN (
        '20250304150604', '20250304150619', '20250304150625', '20250304150632',
        '20250304150637', '20250304150641', '20250304150648', '20250304150651',
        '20250304150656', '20250304150700', '20250304150704', '20250304150708',
        '20250304224026', '20250402230204', '20250619131255', '20250627222953',
        '20250627224343', '20250627232419', '20250627234543', '20250628004048',
        '20250629001621', '20250629002609', '20250629040612', '20250629040639',
        '20250629173000', '20250827142108', '20250827142226', '20250828003903',
        '20250828004217', '20250829173242'
      )
    SQL
    
    puts "Force cleaned orphaned migration references"
  end

  def down
    puts "Cannot rollback force cleanup of orphaned migrations"
  end
end