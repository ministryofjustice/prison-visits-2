class Rejection < ActiveRecord::Base
  NO_ALLOWANCE = 'no_allowance'.freeze
  REASONS = [
    'child_protection_issues',
    'no_adult',
    NO_ALLOWANCE,
    'prisoner_details_incorrect',
    'prisoner_moved',
    'prisoner_non_association',
    'prisoner_released',
    'slot_unavailable',
    'visitor_banned',
    'visitor_not_on_list',
    'duplicate_visit_request'
  ].freeze

  belongs_to :visit

  validates :reason, inclusion: { in: REASONS }
  validate :validate_reasons

  def privileged_allowance_available?
    privileged_allowance_expires_on.present?
  end

  def allowance_will_renew?
    allowance_renews_on.present?
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
end
