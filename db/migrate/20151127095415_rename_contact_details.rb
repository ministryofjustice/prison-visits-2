class RenameContactDetails < ActiveRecord::Migration
  def change
    if column_exists?(:visits, :visitor_email_address)
      rename_column :visits, :visitor_email_address, :contact_email_address
    end

    if column_exists?(:visits, :visitor_phone_no)
      rename_column :visits, :visitor_phone_no, :contact_phone_no
    end
  end
end
