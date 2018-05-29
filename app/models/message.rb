class Message < ApplicationRecord
  belongs_to :user
  belongs_to :visit
  belongs_to :visit_state_change

  validates :body, presence: true
  validates :user_id, presence: true

  def self.create_and_send_email(attrs)
    message = new(attrs)

    VisitorMailer.one_off_message(message).deliver_later if message.save
    message
  end
end
