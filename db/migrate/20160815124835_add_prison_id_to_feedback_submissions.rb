class AddPrisonIdToFeedbackSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :feedback_submissions, :prison_id, :uuid
    add_foreign_key :feedback_submissions, :prisons
  end
end
