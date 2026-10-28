class AddAnonymisationIndexToPrisoners < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  set_statement_timeout(1_800_000)

  def change
    add_index :prisoners, :created_at,
              name: 'index_prisoners_pending_anonymisation',
              where: "first_name <> 'REMOVED'",
              algorithm: :concurrently
  end
end