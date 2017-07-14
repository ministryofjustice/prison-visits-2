class ChangeReasonNullColumn < ActiveRecord::Migration[4.2]
  def change
    change_column_null :rejections, :reason, true
  end
end
