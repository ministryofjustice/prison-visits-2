require 'date_coercer'

class AccessibleDate
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :year, :month, :day

  validate :parsable?
  validates :year, :month, :day, presence: true, if: :any_date_part?

  def attributes
    { year: year, month: month, day: day }
  end

  def to_date
    Date.new(
      *serializable_hash.values_at(:year, :month, :day).map(&:to_i)
    )
  rescue ArgumentError
    nil
  end

private

  def parsable?
    return unless any_date_part?
    unless any_date_part? && DateCoercer.coerce(serializable_hash).is_a?(Date)
      i18n_scope = [:activemodel, :errors, :messages]
      errors.add(:year,  I18n.t('invalid', scope: i18n_scope))
      errors.add(:month, I18n.t('invalid', scope: i18n_scope))
      errors.add(:day,   I18n.t('invalid', scope: i18n_scope))
    end
  end

  def any_date_part?
    attributes.values.any?(&:present?)
  end
end
