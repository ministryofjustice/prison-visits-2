class AddVisitPrisonerSearchIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!
  set_statement_timeout(1_800_000)

  def change
    add_index :visits, :prisoner_id, algorithm: :concurrently
  end
end
