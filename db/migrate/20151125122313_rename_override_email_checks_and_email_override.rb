class RenameOverrideEmailChecksAndEmailOverride < ActiveRecord::Migration[4.2]
  def change
    rename_column :visits, :override_email_checks, :override_spam_or_bounce
    rename_column :visits, :email_override, :spam_or_bounce
  end
end
