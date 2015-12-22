class AddDatetimesForTrackingMetricsToVisit < ActiveRecord::Migration
  def change
    add_column :visits, :accepted_at, :datetime, index: true
    add_column :visits, :rejected_at, :datetime, index: true
    add_column :visits, :withdrawn_at, :datetime, index: true
    add_column :visits, :cancelled_at, :datetime, index: true

    execute <<-SQL
      UPDATE visits SET cancelled_at = now()
      WHERE processing_state = 'rejected'
      AND cancelled_at is NULL
     SQL

    execute <<-SQL
      UPDATE visits SET accepted_at = now()
      WHERE processing_state = 'accepted'
      AND accepted_at is NULL
     SQL

    execute <<-SQL
      UPDATE visits SET rejected_at = now()
      WHERE processing_state = 'rejected'
      AND rejected_at is NULL
     SQL

    execute <<-SQL
      UPDATE visits SET withdrawn_at = now()
      WHERE processing_state = 'withdrawn'
      AND withdrawn_at is NULL
     SQL
  end
end
