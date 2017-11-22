class AddOtherRejectionReasonToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :other_rejection_reason, :boolean, default: false
  end
end
