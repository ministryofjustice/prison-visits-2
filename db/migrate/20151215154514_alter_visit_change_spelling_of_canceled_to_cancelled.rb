class AlterVisitChangeSpellingOfCanceledToCancelled < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      UPDATE visits SET processing_state = 'cancelled'
      WHERE processing_state = 'canceled'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE visits SET processing_state = 'canceled'
      WHERE processing_state = 'cancelled'
    SQL
  end
end
