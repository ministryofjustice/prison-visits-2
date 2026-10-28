class AddRequestedDashboardIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  set_statement_timeout(1_800_000)

  def change
    add_index :visits, %i[prison_id processing_state created_at],
              name: 'index_visits_for_requested_dashboard', algorithm: :concurrently
  end
end
