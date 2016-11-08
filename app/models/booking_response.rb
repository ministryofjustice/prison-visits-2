class BookingResponse
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  ADULT_AGE = 18
  attr_accessor :visit, :user

  before_validation :check_slot_available

  validate :validate_visit_is_processable
  validate :visit_or_rejection_validity

  after_validation :check_for_banned_visitors
  after_validation :check_for_unlisted_visitors
  after_validation :check_at_least_one_adult_visitor

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def email_attrs
    attrs = visit.serializable_hash(
      except: [
        :created_at,
        :updated_at,
        :slot_granted,
        :slot_option_0,
        :slot_option_1,
        :slot_option_2
      ],
      methods: [
        :principal_visitor_id
      ]
    ).merge(
      'slot_option_0' => visit.slot_option_0.to_s,
      'slot_option_1' => visit.slot_option_1.to_s,
      'slot_option_2' => visit.slot_option_2.to_s,
      'slot_granted'  => visit.slot_granted.to_s
    )
    attrs['rejection_attributes'] = rejection_attributes if rejection_attributes
    attrs['visitors_attributes']  = visitors_attributes  if visitors_attributes
    attrs
  end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize

private

  # rubocop:disable Metrics/MethodLength
  def rejection_attributes
    return unless visit.rejection&.valid?
    @rejection_attributes ||= begin
      attrs = visit.rejection.serializable_hash(
        except: [
          :created_at, :updated_at, :allowance_renews_on,
          :privileged_allowance_expires_on
        ])

      attrs['allowance_renews_on'] =
        rejection.allowance_renews_on.to_s
      attrs
    end
  end
  # rubocop:enable Metrics/MethodLength

  def visitors_attributes
    @visitors_attributes ||= begin
      attrs = {}
      visit.visitors.each_with_object(attrs).with_index do |(visitor, attr), i|
        attr[i.to_s] = visitor.attributes.slice('id', 'not_on_list', 'banned')
      end
      attrs
    end
  end

  def visit_or_rejection_validity
    case [visit.slot_granted?, rejection.valid?, at_least_one_valid_visitor?]
    when [true, true, true], [false, false, true]
      errors.add(
        :base,
        I18n.t('must_reject_or_accept_visit',
          scope: [:booking_response, :errors])
      )
    end
  end

  def rejection
    @rejection ||= @visit.rejection || @visit.build_rejection
  end

  def check_at_least_one_adult_visitor
    unless at_least_one_valid_visitor?
      rejection.reasons << Rejection::NO_ADULT
    end
  end

  def at_least_one_valid_visitor?
    visit.visitors.
      reject(&:not_on_list?).
      reject(&:banned?).
      any? { |visitor| visitor.age >= ADULT_AGE }
  end

  def check_slot_available
    if visit.attributes['slot_granted'] == Rejection::SLOT_UNAVAILABLE
      rejection.reasons << Rejection::SLOT_UNAVAILABLE
      visit.slot_granted = nil
    end
  end

  def check_for_banned_visitors
    return if at_least_one_valid_visitor?
    if all_visitor_banned?
      rejection.reasons << Rejection::BANNED
    end
  end

  def check_for_unlisted_visitors
    return if at_least_one_valid_visitor?
    if all_visitor_not_on_list?
      rejection.reasons << Rejection::NOT_ON_THE_LIST
    end
  end

  def all_visitor_banned?
    visit.visitors.all?(&:banned)
  end

  def all_visitor_not_on_list?
    visit.visitors.all?(&:not_on_list)
  end

  def validate_visit_is_processable
    unless visit.processable?
      errors.add(:visit, :already_processed)
    end
  end
end
