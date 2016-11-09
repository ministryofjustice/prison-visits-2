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

  validate :check_allowance_renews_on_is_date

  # TODO: Delete me when the column has dropped
  def self.columns
    super.reject { |c| c.name == 'reason' }
  end

  def allowance_will_renew?
    allowance_renews_on.is_a?(Date)
  end

private

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

  def truthy?(value)
    ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.
      include?(value)
  end

  def check_allowance_renews_on_is_date
    if no_allowance? &&
       allowance_renews_on.present? &&
       !allowance_renews_on.is_a?(Date)
      errors.add(:allowance_renews_on, :invalid)
    end
  end

  def no_allowance?
    reasons.include?(NO_ALLOWANCE)
  end
end
