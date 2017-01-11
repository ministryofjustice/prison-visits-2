# frozen_string_literal: true
require 'date_coercer'

class Rejection < ActiveRecord::Base
  NO_ALLOWANCE     = 'no_allowance'
  NOT_ON_THE_LIST  = 'visitor_not_on_list'
  BANNED           = 'visitor_banned'
  SLOT_UNAVAILABLE = 'slot_unavailable'
  NO_ADULT         = 'no_adult'
  PRISONER_DETAILS_INCORRECT =
    'prisoner_details_incorrect'
  PRISONER_NON_ASSOCIATION =
    'prisoner_non_association'
  CHILD_PROTECTION_ISSUES =
    'child_protection_issues'

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
    'duplicate_visit_request'
  ].freeze

  belongs_to :visit, inverse_of: :rejection

  validate :validate_reasons
  validates :reasons, presence: true
  validate :validate_allowance_renews_on_date

  # TODO: Delete me when the column has dropped
  def self.columns
    super.reject { |c| c.name == 'reason' }
  end

  def allowance_will_renew?
    allowance_renews_on.is_a?(Date)
  end

  def allowance_renews_on=(accessible_date)
    date = AccessibleDate.new(accessible_date)
    if date.valid?
      super(date.to_date)
    else
      super(accessible_date)
    end
  rescue
    super DateCoercer.coerce(accessible_date)
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
    allowance_renews_on.is_a?(Date) || allowance_renews_on.nil?
  end

  def no_allowance?
    reasons.include?(Rejection::NO_ALLOWANCE)
  end
end
