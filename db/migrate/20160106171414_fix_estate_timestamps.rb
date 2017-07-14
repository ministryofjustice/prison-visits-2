class FixEstateTimestamps < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      UPDATE estates
      SET created_at = now(), updated_at = now()
      WHERE created_at IS NULL
    SQL
  end

  def down
  end
end
