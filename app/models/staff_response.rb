class StaffResponse
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  ADULT_AGE = 18
  attr_accessor :visit, :user

  alias_method :creator, :user

  before_validation :check_slot_available
  before_validation :check_principal_visitor

  validate :validate_visit_is_processable
  validate :visit_or_rejection_validity
  validate :visitors_selection

  after_validation :check_for_banned_visitors
  after_validation :check_for_unlisted_visitors

  after_validation :clear_allowance_renews_on_date
  after_validation :sanitise_reasons
  def email_attrs
    attrs = visit.serializable_hash(
      except: [
        :created_at,
        :updated_at,
        :slot_granted,
        :slot_option_0,
        :slot_option_1,
        :slot_option_2,
        :nomis_id,
        :human_id
      ],
      methods: [
        :principal_visitor_id
      ]
    ).merge(
      'slot_option_0' => visit.slot_option_0.to_s,
      'slot_option_1' => visit.slot_option_1.to_s,
      'slot_option_2' => visit.slot_option_2.to_s,
      'slot_granted' => visit.slot_granted.to_s
    )
    attrs['rejection_attributes'] = rejection_attributes if rejection_attributes
    attrs['visitors_attributes']  = visitors_attributes  if visitors_attributes
    attrs
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def validate_visitors_nomis_ready=(val)
    @validate_visitors_nomis_ready ||= ActiveRecord::Type::Boolean
      .new
      .cast(val)
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def validate_visitors_nomis_ready?
    @validate_visitors_nomis_ready
  end

private

  def rejection_attributes
    return unless visit.rejection&.valid?

    @rejection_attributes ||= begin
      attrs = visit.rejection.serializable_hash(
        except: %i[
created_at
updated_at
allowance_renews_on
privileged_allowance_expires_on
rejection_reason_detail])

      attrs['allowance_renews_on'] =
        rejection.allowance_renews_on.to_s
      attrs
    end
  end

  def visitors_attributes
    @visitors_attributes ||= begin
      fields = %w[id not_on_list banned other_rejection_reason]

      visit.visitors.each_with_object({}).with_index do |(visitor, attrs), i|
        attrs[i.to_s] = visitor.attributes.slice(*fields)
        attrs[i.to_s]['banned_until'] = visitor.banned_until.to_s
      end
    end
  end

  def visit_or_rejection_validity
    case [visit.slot_granted?, rejection.valid?]
    when [true, true], [false, false]
      errors.add(
        :base,
        I18n.t('must_reject_or_accept_visit',
               scope: %i[staff_response errors])
      )
    end
  end

  def rejection
    @rejection ||= @visit.rejection || @visit.build_rejection
  end

  def check_principal_visitor
    if principal_visitor.banned?
      rejection.reasons << Rejection::BANNED
      visit.slot_granted = nil
    elsif principal_visitor.not_on_list?
      rejection.reasons << Rejection::NOT_ON_THE_LIST
      visit.slot_granted = nil
    elsif principal_visitor.other_rejection_reason?
      rejection.reasons << Rejection::VISITOR_OTHER_REASON
      visit.slot_granted = nil
    end
  end

  def check_slot_available
    if visit.attributes['slot_granted'] == Rejection::SLOT_UNAVAILABLE
      rejection.reasons << Rejection::SLOT_UNAVAILABLE
      visit.slot_granted = nil
    end
  end

  def check_for_banned_visitors
    rejection.reasons << Rejection::BANNED if all_visitor_banned?
  end

  def check_for_unlisted_visitors
    rejection.reasons << Rejection::NOT_ON_THE_LIST if all_visitor_not_on_list?
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

  def clear_allowance_renews_on_date
    unless rejection.reasons.include?(Rejection::NO_ALLOWANCE)
      rejection.allowance_renews_on = nil
    end
  end

  def visitors_selection
    return unless validate_visitors_nomis_ready?
    return if rejection_reasons?

    invalid_visitors = visit.visitors.select { |visitor|
      visitor.nomis_id.present? == visitor.not_on_list?
    }

    invalid_visitors.each do |v|
      v.errors.add :base, :unprocessed_contact_list
    end

    errors.add(:base, :visitors_invalid) if invalid_visitors.any?
  end

  def principal_visitor
    visit.principal_visitor
  end

  def sanitise_reasons
    rejection.reasons.uniq!
  end

  def rejection_reasons?
    rejection.reasons.any?
  end
end
