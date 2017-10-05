class ChangeCancellationReasonsNullable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :cancellations, :reason, true
    change_column_null :cancellations, :reasons, false
  end
end
