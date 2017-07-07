class AddSubmittedByStaffToFeedbackSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :feedback_submissions, :submitted_by_staff, :boolean, default: false, null: false
  end
end
