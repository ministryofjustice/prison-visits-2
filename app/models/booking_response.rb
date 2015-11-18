class BookingResponse
  include NonPersistedModel

  SLOTS = %w[ slot_0 slot_1 slot_2 ]
  REJECTION_REASONS = %w[
    slot_unavailable
    no_allowance
  ]

  attribute :visit

  attribute :selection, Integer
  validates :selection, inclusion: { in: SLOTS + REJECTION_REASONS }

  attribute :reference_no, String
  validates :reference_no, presence: true, if: :slot_selected?
  attribute :closed_visit, Virtus::Attribute::Boolean

  attribute :vo_will_be_renewed, Virtus::Attribute::Boolean
  attribute :vo_renewed_on, Date
  validates :vo_renewed_on, presence: true, if: :vo_will_be_renewed
  attribute :pvo_possible, Virtus::Attribute::Boolean
  attribute :pvo_expires_on, Date
  validates :pvo_expires_on, presence: true, if: :pvo_possible

  delegate :slots, :prison, :to_param,
    :prisoner_full_name, :prisoner_number, :prisoner_date_of_birth,
    :visitor_full_name, :visitor_age, :visitor_date_of_birth,
    :visitor_email_address, :visitor_phone_no,
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
