class Visit < ActiveRecord::Base
  belongs_to :prison
  has_many :additional_visitors
  has_one :rejection

  validates :prison_id, :prisoner_first_name, :prisoner_last_name,
    :prisoner_date_of_birth, :prisoner_number,
    :visitor_first_name, :visitor_last_name, :visitor_date_of_birth,
    :visitor_email_address, :visitor_phone_no, :slot_option_0,
    :processing_state,
    presence: true

  validates :email_override,
    inclusion: { in: %w[ bounced spam_reported ] },
    allow_nil: true

  delegate :email_address, :phone_no, :name, to: :prison, prefix: true
  alias_attribute :recipient, :visitor_email_address
  alias_attribute :first_date, :slot_option_0

  def total_number_of_visitors
    additional_visitors.count + 1
  end

  delegate :reason, to: :rejection, prefix: true

  state_machine :processing_state, initial: :requested do
    event :accept do
      transition requested: :booked
    end

    event :reject do
      transition requested: :rejected
    end
  end

  extend Names
  enhance_names prefix: :prisoner
  enhance_names prefix: :visitor

  def prisoner_age
    AgeCalculator.new.age(prisoner_date_of_birth)
  end

  def visitor_age
    AgeCalculator.new.age(visitor_date_of_birth)
  end

  def slots
    [slot_option_0, slot_option_1, slot_option_2].
      select(&:present?).map { |s| ConcreteSlot.parse(s) }
  end

  def slot_granted
    super ? ConcreteSlot.parse(super) : nil
  end

  def date
    slot_granted.begin_at
  end

  def confirm_by
    prison.confirm_by(created_at.to_date)
  end
end
