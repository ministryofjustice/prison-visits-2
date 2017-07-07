class RemoveDatetimesForTrackingMetricsFromVisit < ActiveRecord::Migration[4.2]
  def change
    remove_column :visits, :accepted_at
    remove_column :visits, :rejected_at
    remove_column :visits, :withdrawn_at
    remove_column :visits, :cancelled_at
  end
end
