require 'maybe_date'

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
  attribute :allowance_renews_on, MaybeDate
  validates :allowance_renews_on,
    presence: true,
    if: :allowance_will_renew
  validate :validate_allowance_renews_on, if: :allowance_will_renew

  attribute :privileged_allowance_available, Virtus::Attribute::Boolean
  attribute :privileged_allowance_expires_on, MaybeDate
  validates :privileged_allowance_expires_on,
    presence: true,
    if: :privileged_allowance_available
  validate :validate_privileged_allowance_expires_on, if: :privileged_allowance_available

  attribute :unlisted_visitor_ids, Array
  attribute :banned_visitor_ids, Array
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
    return 'visitor_not_on_list' if unlisted_visitor_ids.any?
    return 'visitor_banned' if banned_visitor_ids.any?
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
    visitors.select { |v| unlisted_visitor_ids.include?(v.id) }
  end

  def banned_visitors
    visitors.select { |v| banned_visitor_ids.include?(v.id) }
  end

private
  def validate_allowance_renews_on
    unless allowance_renews_on && allowance_renews_on.is_a?(Date)
      errors.add :allowance_renews_on, :invalid
    end
  end

  def validate_privileged_allowance_expires_on
    unless privileged_allowance_expires_on && privileged_allowance_expires_on.is_a?(Date)
      errors.add :privileged_allowance_expires_on, :invalid
    end
  end

  def at_least_one_valid_visitor?
    visitors.
      reject { |visitor| visitor.in? unlisted_visitors }.
      reject { |visitor| visitor.in? banned_visitors }.
      any? { |visitor| visitor.age >= ADULT_AGE }
  end

  def validate_visit_is_processable
    unless visit.processable?
      errors.add :visit, :already_processed
    end
  end
  validate :validate_visit_is_processable
end
