class AddAnonymisationIndexToVisitors < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  set_statement_timeout(1_800_000)

  def change
    add_index :visitors, :created_at,
              name: 'index_visitors_pending_anonymisation',
              where: "first_name <> 'REMOVED'",
              algorithm: :concurrently
  end
end