class RenameContactDetails < ActiveRecord::Migration
  def change
    rename_column :visits, :visitor_email_address, :contact_email_address
    rename_column :visits, :visitor_phone_no, :contact_phone_no
  end
end
