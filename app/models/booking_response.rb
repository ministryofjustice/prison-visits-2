require 'maybe_date'

class BookingResponse
  include NonPersistedModel

  SLOTS = %w[ slot_0 slot_1 slot_2 ]

  # The adult age for accepting a booking is different from the configurable
  # adult age in Prison
  ADULT_AGE = 18

  attribute :visit, Visit

  attribute :selection, String, default: 'none'
  validates :selection,
    inclusion: { in: SLOTS + Rejection::REASONS },
    if: :at_least_one_valid_visitor?

  attribute :reference_no, String
  validates :reference_no, presence: true, if: :bookable?
  attribute :closed_visit, Virtus::Attribute::Boolean

  attribute :allowance_will_renew, Virtus::Attribute::Boolean
  attribute :allowance_renews_on, MaybeDate

  with_options if: :allowance_will_renew do
    validates :allowance_renews_on, presence: true
    validate :validate_allowance_renews_on
  end

  attribute :privileged_allowance_available, Virtus::Attribute::Boolean
  attribute :privileged_allowance_expires_on, MaybeDate

  with_options if: :privileged_allowance_available do
    validates :privileged_allowance_expires_on, presence: true
    validate :validate_privileged_allowance_expires_on
  end

  attribute :unlisted_visitor_ids, Array
  attribute :banned_visitor_ids, Array
  attribute :message_body, String
  attribute :user, User

  delegate :contact_email_address,
    :contact_phone_no,
    :closed?,
    :id,
    :prisoner_anonymized_name,
    :prisoner_date_of_birth,
    :prisoner_first_name,
    :prisoner_full_name,
    :prisoner_last_name,
    :prisoner_number,
    :prison,
    :prison_email_address,
    :prison_id,
    :prison_name,
    :prison_phone_no,
    :processable?,
    :processing_state_name,
    :to_param,
    :slots,
    :visitor_full_name,
    :visitors,
    to: :visit
  delegate :name,     to: :prison, prefix: true
  delegate :visitors, to: :visit
  delegate :principal_visitor, to: :visit
  delegate :additional_visitors, to: :visit

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

  def slot_granted
    slots.fetch(slot_index)
  end

  def allowed_visitors
    visitors.reject { |v| not_allowed_visitor_ids.include?(v.id) }
  end

  def unlisted_visitors
    visitors.select { |v| unlisted_visitor_ids.include?(v.id) }
  end

  def banned_visitors
    visitors.select { |v| banned_visitor_ids.include?(v.id) }
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def email_attrs
    attrs = {
      visit_id:             visit.id,
      selection:            selection,
      reference_no:         reference_no,
      closed_visit:         closed_visit,
      allowance_will_renew: allowance_will_renew,
      unlisted_visitor_ids: unlisted_visitor_ids,
      user_id:              user.try(:id),
      banned_visitor_ids:   banned_visitor_ids,
      message_body:         message_body,
      privileged_allowance_available: privileged_allowance_available
    }

    if allowance_renews_on.is_a?(Date)
      attrs[:allowance_renews_on] = allowance_renews_on.to_s
    end

    if privileged_allowance_expires_on.is_a?(Date)
      attrs[:privileged_allowance_expires_on] =
        privileged_allowance_expires_on.to_s
    end

    attrs
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def no_allowance?
    selection == Rejection::NO_ALLOWANCE
  end

private

  def slot_index
    SLOTS.index(selection)
  end

  def validate_allowance_renews_on
    unless allowance_renews_on && allowance_renews_on.is_a?(Date)
      errors.add :allowance_renews_on, :invalid
    end
  end

  def validate_privileged_allowance_expires_on
    unless privileged_allowance_expires_on &&
           privileged_allowance_expires_on.is_a?(Date)
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

  def not_allowed_visitor_ids
    @not_allowed_visitor_ids ||=
      unlisted_visitor_ids + banned_visitor_ids
  end
end
