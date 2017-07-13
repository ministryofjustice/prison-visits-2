require 'date_coercer'

class Rejection < ActiveRecord::Base
  NO_ALLOWANCE     = 'no_allowance'.freeze
  NOT_ON_THE_LIST  = 'visitor_not_on_list'.freeze
  BANNED           = 'visitor_banned'.freeze
  SLOT_UNAVAILABLE = 'slot_unavailable'.freeze
  NO_ADULT         = 'no_adult'.freeze
  PRISONER_DETAILS_INCORRECT =
    'prisoner_details_incorrect'.freeze
  PRISONER_NON_ASSOCIATION =
    'prisoner_non_association'.freeze
  CHILD_PROTECTION_ISSUES =
    'child_protection_issues'.freeze
  PRISONER_BANNED = 'prisoner_banned'.freeze
  PRISONER_OUT_OF_PRISON = 'prisoner_out_of_prison'.freeze

  REASONS = [
    CHILD_PROTECTION_ISSUES,
    NO_ADULT,
    NO_ALLOWANCE,
    PRISONER_DETAILS_INCORRECT,
    'prisoner_moved',
    PRISONER_NON_ASSOCIATION,
    'prisoner_released',
    SLOT_UNAVAILABLE,
    BANNED,
    NOT_ON_THE_LIST,
    'duplicate_visit_request',
    PRISONER_BANNED,
    PRISONER_OUT_OF_PRISON
  ].freeze

  belongs_to :visit, inverse_of: :rejection

  validate :validate_reasons
  validates :reasons, presence: true
  validate :validate_allowance_renews_on_date
  def allowance_will_renew?
    allowance_renews_on.is_a?(Date)
  end

private

  def validate_allowance_renews_on_date
    if no_allowance? && !acceptable_allowance_renews_on_date?
      errors.add(:allowance_renews_on, :invalid)
    end
  end

  def validate_reasons
    reasons.each do |r|
      next if REASONS.include?(r)
      errors.add(
        :reasons,
        I18n.t(
          'activerecord.errors.models.rejection.invalid_reason',
          reason: r
        )
      )
    end
  end

  def acceptable_allowance_renews_on_date?
    allowance_renews_on.is_a?(Date) || as_accessible_date.valid?
  end

  def no_allowance?
    reasons.include?(Rejection::NO_ALLOWANCE)
  end

  def as_accessible_date
    AccessibleDate.from_multi_parameters(
      allowance_renews_on_before_type_cast
    )
  end
end
