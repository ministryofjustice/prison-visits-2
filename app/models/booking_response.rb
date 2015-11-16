class BookingResponse
  include NonPersistedModel

  attribute :visit

  attribute :selection, Integer
  validates :selection,
    inclusion: {
      in: %w[
        slot_0 slot_1 slot_2
        slot_unavailable
      ]
    }

  attribute :reference_no, String
  validates :reference_no, presence: true, if: :slot_selected?
  attribute :closed_visit, Virtus::Attribute::Boolean

  delegate :slots, :prison, :to_param,
    :prisoner_full_name, :prisoner_number, :prisoner_date_of_birth,
    :visitor_full_name, :visitor_age, :visitor_date_of_birth,
    :visitor_email_address, :visitor_phone_no,
    :additional_visitors,
    to: :visit
  delegate :name, to: :prison, prefix: true

  def slot_selected?
    %w[ slot_0 slot_1 slot_2 ].include?(selection)
  end
end
