class Visit < ActiveRecord::Base
  belongs_to :prison
  has_many :additional_visitors

  validates :prison_id, :prisoner_first_name, :prisoner_last_name,
    :prisoner_date_of_birth, :prisoner_number,
    :visitor_first_name, :visitor_last_name, :visitor_date_of_birth,
    :visitor_email_address, :visitor_phone_no, :slot_option_1,
    :processing_state,
    presence: true

  delegate :email_address, to: :prison, prefix: true

  before_create :set_reference_number

  def prisoner_full_name
    [prisoner_first_name, prisoner_last_name].join(' ')
  end

  def visitor_full_name
    [visitor_first_name, visitor_last_name].join(' ')
  end

  def prisoner_age
    AgeCalculator.new.age(prisoner_date_of_birth)
  end

  def visitor_age
    AgeCalculator.new.age(visitor_date_of_birth)
  end

  def slots
    [slot_option_1, slot_option_2, slot_option_3].
      select(&:present?).map { |s| ConcreteSlot.parse(s) }
  end

private

  def set_reference_number
    self.reference_number = SecureRandom.uuid
  end
end
