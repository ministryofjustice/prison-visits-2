class AddAnonymisationIndexToVisits < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  set_statement_timeout(1_800_000)

  def change
    add_index :visits, :created_at,
              name: 'index_visits_pending_anonymisation',
              where: "contact_email_address <> 'REMOVED'",
              algorithm: :concurrently
  end
end