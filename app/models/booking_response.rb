class BookingResponse
  include NonPersistedModel

  SLOTS = %w[ slot_0 slot_1 slot_2 ]

  attribute :visit

  attribute :selection, String
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

  attribute :unlisted_visitor_ids, Array
  attribute :banned_visitor_ids, Array

  delegate :slots, :prison, :to_param,
    :prisoner_full_name, :prisoner_number, :prisoner_date_of_birth,
    :contact_email_address, :contact_phone_no,
    :visitors,
    to: :visit
  delegate :name, to: :prison, prefix: true
  delegate :visitors, to: :visit
  delegate :inquiry, to: :selection, prefix: true
  delegate :no_allowance?, :visitor_not_on_list?, :visitor_banned?,
    to: :selection_inquiry

  def slot_selected?
    SLOTS.include?(selection)
  end

  def slot_index
    SLOTS.index(selection)
  end

  def unlisted_visitors
    visitors.select { |v| unlisted_visitor_ids.include?(v.id) }
  end

  def banned_visitors
    visitors.select { |v| banned_visitor_ids.include?(v.id) }
  end

private

  def validate_checked_visitors
    if visitor_not_on_list? && unlisted_visitor_ids.empty?
      errors.add :selection, :no_unlisted_visitors_selected
    elsif visitor_banned? && banned_visitor_ids.empty?
      errors.add :selection, :no_banned_visitors_selected
    end
  end
  validate :validate_checked_visitors
end
