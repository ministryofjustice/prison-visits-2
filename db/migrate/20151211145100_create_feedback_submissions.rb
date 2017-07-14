class CreateFeedbackSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :feedback_submissions, id: :uuid do |t|
      t.text :body, null: false
      t.string :email_address
      t.string :referrer
      t.string :user_agent
    end
  end
end
