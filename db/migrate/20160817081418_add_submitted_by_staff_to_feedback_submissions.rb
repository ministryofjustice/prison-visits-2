class AddSubmittedByStaffToFeedbackSubmissions < ActiveRecord::Migration
  def change
    add_column :feedback_submissions, :submitted_by_staff, :boolean, default: false, null: false
  end
end
