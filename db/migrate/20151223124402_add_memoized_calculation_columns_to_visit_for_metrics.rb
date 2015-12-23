class AddMemoizedCalculationColumnsToVisitForMetrics < ActiveRecord::Migration
  def change
    add_column :visits, :days_to_process, :float, index: true

    execute <<-SQL
      UPDATE visits SET accepted_at = now()
      WHERE processing_state = 'booked'
      AND accepted_at is NULL
    SQL

    execute <<-SQL
      UPDATE visits SET days_to_process = accepted_at::date - created_at::date
      WHERE processing_state = 'booked'
      AND accepted_at IS NOT NULL
      AND days_to_process IS NULL
    SQL

    execute <<-SQL
      UPDATE visits SET days_to_process = rejected_at::date - created_at::date
      WHERE processing_state = 'rejected'
      AND rejected_at IS NOT NULL
      AND days_to_process IS NULL
    SQL
  end
end
