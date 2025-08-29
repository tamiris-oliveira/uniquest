class CleanupOrphanedMigrations < ActiveRecord::Migration[8.0]
  def up
    # Lista de todas as migrações órfãs que foram removidas
    orphaned_migrations = [
      '20250304150604', '20250304150619', '20250304150625', '20250304150632',
      '20250304150637', '20250304150641', '20250304150648', '20250304150651',
      '20250304150656', '20250304150700', '20250304150704', '20250304150708',
      '20250304224026', '20250402230204', '20250619131255', '20250627222953',
      '20250627224343', '20250627232419', '20250627234543', '20250628004048',
      '20250629001621', '20250629002609', '20250629040612', '20250629040639',
      '20250629173000', '20250827142108', '20250827142226', '20250828003903',
      '20250828004217', '20250829173242'
    ]
    
    # Remove as referências órfãs da tabela schema_migrations de forma segura
    removed_count = 0
    orphaned_migrations.each do |version|
      begin
        result = execute "DELETE FROM schema_migrations WHERE version = '#{version}'"
        removed_count += 1 if result
      rescue => e
        puts "Warning: Could not remove migration #{version}: #{e.message}"
      end
    end
    
    puts "Removed #{removed_count} orphaned migration references"
  end

  def down
    # Não há como reverter esta operação de forma segura
    # pois não sabemos quais migrações realmente existiam antes
    puts "Cannot rollback cleanup of orphaned migrations"
  end
end