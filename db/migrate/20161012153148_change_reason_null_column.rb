class ChangeReasonNullColumn < ActiveRecord::Migration
  def change
    change_column_null :rejections, :reason, true
  end
end
