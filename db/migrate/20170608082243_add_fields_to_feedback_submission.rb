class AddFieldsToFeedbackSubmission < ActiveRecord::Migration
  def change
    add_column :feedback_submissions, :prisoner_number, :string
    add_column :feedback_submissions, :prisoner_date_of_birth, :date
  end
end
