require_relative 'logs_migration'
class AddPurgedAtToLogs < LogsMigration
  def self.up
    unless column_exists?(:logs, :purged_at)
      add_column :logs, :purged_at, :timestamp
    end
  end

  def self.down
    if column_exists?(:logs, :purged_at)
      remove_column :logs, :purged_at
    end
  end
end