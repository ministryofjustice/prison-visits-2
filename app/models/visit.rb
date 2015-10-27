class Visit < ActiveRecord::Base
  belongs_to :prison
  has_many :additional_visitors

  validates :prison_id, :prisoner_first_name, :prisoner_last_name,
    :prisoner_date_of_birth, :prisoner_number,
    :visitor_first_name, :visitor_last_name, :visitor_date_of_birth,
    :visitor_email_address, :visitor_phone_no, :slot_option_1,
    :processing_state,
    presence: true
end
