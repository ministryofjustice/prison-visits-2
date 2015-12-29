class AddMemoizedCalculationColumnsToVisitForMetrics < ActiveRecord::Migration
  def change
    add_column :visits, :seconds_to_process, :integer, index: true

    execute <<-SQL
      UPDATE visits SET accepted_at = now()
      WHERE processing_state = 'booked'
      AND accepted_at is NULL
    SQL

    execute <<-SQL
      UPDATE visits SET seconds_to_process = EXTRACT(EPOCH FROM accepted_at - created_at)
      WHERE processing_state = 'booked'
      AND accepted_at IS NOT NULL
      AND seconds_to_process IS NULL
    SQL

    execute <<-SQL
      UPDATE visits SET seconds_to_process = EXTRACT(EPOCH FROM rejected_at - created_at)
      WHERE processing_state = 'rejected'
      AND rejected_at IS NOT NULL
      AND seconds_to_process IS NULL
    SQL

    execute <<-SQL
      UPDATE visits SET seconds_to_process = EXTRACT(EPOCH FROM withdrawn_at - created_at)
      WHERE processing_state = 'withdrawn'
      AND withdrawn_at IS NOT NULL
      AND seconds_to_process IS NULL
    SQL

    execute <<-SQL
      UPDATE visits SET seconds_to_process = EXTRACT(EPOCH FROM cancelled_at - created_at)
      WHERE processing_state = 'cancelled'
      AND cancelled_at IS NOT NULL
      AND seconds_to_process IS NULL
    SQL
  end
end
