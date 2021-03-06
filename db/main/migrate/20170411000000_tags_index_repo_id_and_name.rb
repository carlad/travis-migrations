class TagsIndexRepoIdAndName < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE UNIQUE INDEX CONCURRENTLY index_tags_on_repository_id_and_name ON tags (repository_id, name);"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_tags_on_repository_id_and_name"
  end
end
