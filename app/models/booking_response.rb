class BookingResponse
  include NonPersistedModel

  SLOTS = %w[ slot_0 slot_1 slot_2 ]

  # The adult age for accepting a booking is different from the configurable
  # adult age in Prison
  ADULT_AGE = 18

  attribute :visit

  attribute :selection, String, default: 'none'
  validates :selection,
    inclusion: { in: SLOTS + Rejection::REASONS },
    if: :at_least_one_valid_visitor?

  attribute :reference_no, String
  validates :reference_no, presence: true, if: :bookable?
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
  attribute :visitor_not_on_list, Virtus::Attribute::Boolean
  attribute :visitor_banned, Virtus::Attribute::Boolean
  attribute :message_body, String
  attribute :user, User

  delegate :slots, :prison, :to_param,
    :prisoner_full_name, :prisoner_number, :prisoner_date_of_birth,
    :prisoner_first_name, :prisoner_last_name,
    :contact_email_address, :contact_phone_no,
    :visitors,
    :processable?, :processing_state_name,
    to: :visit
  delegate :name, to: :prison, prefix: true
  delegate :visitors, to: :visit
  delegate :inquiry, to: :selection, prefix: true
  delegate :no_allowance?, to: :selection_inquiry

  def reason
    return 'visitor_not_on_list' if visitor_not_on_list?
    return 'visitor_banned' if visitor_banned?
    return 'no_adult' unless at_least_one_valid_visitor?
    selection
  end

  def bookable?
    slot_selected? && at_least_one_valid_visitor?
  end

  def slot_selected?
    SLOTS.include?(selection)
  end

  def slot_index
    SLOTS.index(selection)
  end

  def unlisted_visitors
    return [] unless visitor_not_on_list

    visitors.select { |v| unlisted_visitor_ids.include?(v.id) }
  end

  def banned_visitors
    return [] unless visitor_banned

    visitors.select { |v| banned_visitor_ids.include?(v.id) }
  end

private

  def at_least_one_valid_visitor?
    visitors.
      reject { |visitor| visitor.in? unlisted_visitors }.
      reject { |visitor| visitor.in? banned_visitors }.
      any? { |visitor| visitor.age >= ADULT_AGE }
  end

  def validate_checked_visitors
    if visitor_not_on_list? && unlisted_visitor_ids.empty?
      errors.add :visitor_not_on_list, :no_unlisted_visitors_selected
    elsif visitor_banned? && banned_visitor_ids.empty?
      errors.add :visitor_banned, :no_banned_visitors_selected
    end
  end
  validate :validate_checked_visitors

  def validate_visit_is_processable
    unless visit.processable?
      errors.add :visit, :already_processed
    end
  end
  validate :validate_visit_is_processable
end
