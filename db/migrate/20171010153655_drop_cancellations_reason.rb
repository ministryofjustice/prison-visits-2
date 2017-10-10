class DropCancellationsReason < ActiveRecord::Migration[5.1]
  def change
    remove_column :cancellations, :reason
  end
end
