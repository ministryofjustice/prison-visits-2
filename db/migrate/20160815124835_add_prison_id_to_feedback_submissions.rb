class AddPrisonIdToFeedbackSubmissions < ActiveRecord::Migration
  def change
    add_column :feedback_submissions, :prison_id, :uuid
    add_foreign_key :feedback_submissions, :prisons
  end
end
