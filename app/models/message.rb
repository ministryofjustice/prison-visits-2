class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :visit
  belongs_to :visit_state_change

  validates :body, presence: true
  validates :user_id, presence: true
end
