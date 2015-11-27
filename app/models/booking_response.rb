class BookingResponse
  include NonPersistedModel

  SLOTS = %w[ slot_0 slot_1 slot_2 ]

  attribute :visit

  attribute :selection, Integer
  validates :selection, inclusion: { in: SLOTS + Rejection::REASONS }

  attribute :reference_no, String
  validates :reference_no, presence: true, if: :slot_selected?
  attribute :closed_visit, Virtus::Attribute::Boolean

  attribute :allowance_will_renew, Virtus::Attribute::Boolean
  attribute :allowance_renews_on, Date
  validates :allowance_renews_on,
    presence: true,
    if: :allowance_will_renew

  attribute :privileged_allowance_available, Virtus::Attribute::Boolean
  attribute :privileged_allowance_expires_on, Date
  validates :privileged_allowance_expires_on,
    presence: true,
    if: :privileged_allowance_available

  delegate :slots, :prison, :to_param,
    :prisoner_full_name, :prisoner_number, :prisoner_date_of_birth,
    :visitor_full_name, :visitor_age, :visitor_date_of_birth,
    :contact_email_address, :contact_phone_no,
    :additional_visitors,
    to: :visit
  delegate :name, to: :prison, prefix: true

  def slot_selected?
    SLOTS.include?(selection)
  end

  def no_allowance?
    selection == 'no_allowance'
  end

  def slot_index
    SLOTS.index(selection)
  end
end
