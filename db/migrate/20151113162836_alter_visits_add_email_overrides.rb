class AlterVisitsAddEmailOverrides < ActiveRecord::Migration[4.2]
  def change
    add_column :visits, :override_email_checks, :boolean, default: false
    add_column :visits, :email_override, :string
  end
end
