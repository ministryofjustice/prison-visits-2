class AlterVisitorSetDefaultsForBannedAndNotOnList < ActiveRecord::Migration
  def change
    change_column_default :visitors, :banned, false
    change_column_default :visitors, :not_on_list, false

    execute "UPDATE visitors SET banned = FALSE WHERE banned IS NULL"
    execute "UPDATE visitors SET not_on_list = FALSE WHERE not_on_list IS NULL"
  end
end
