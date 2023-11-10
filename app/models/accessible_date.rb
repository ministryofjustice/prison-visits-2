require 'date_coercer'

class AccessibleDate
  include MemoryModel
  include ActiveModel::Serialization

  attribute :year, :integer
  attribute :month, :integer
  attribute :day, :integer

  validate :parsable?
  validates :year, :month, :day, presence: true, if: :any_date_part?

  def attributes
    { year:, month:, day: }
  end

  def to_date
    return nil if attributes.values.any?(&:blank?)

    Date.new(*attributes.values)
  rescue ArgumentError
    nil
  end

  def self.from_multi_parameters(before_type_cast_value)
    return new unless before_type_cast_value.respond_to?(:values_at)

    new(Hash[[:year, :month, :day].zip(before_type_cast_value.values_at(1, 2, 3))])
  end

private

  def parsable?
    return unless any_date_part?

    unless any_date_part? && DateCoercer.coerce(serializable_hash).is_a?(Date)
      i18n_scope = %i[activemodel errors messages]
      errors.add(:year,  I18n.t('invalid', scope: i18n_scope))
      errors.add(:month, I18n.t('invalid', scope: i18n_scope))
      errors.add(:day,   I18n.t('invalid', scope: i18n_scope))
    end
  end

  def any_date_part?
    attributes.values.any?(&:present?)
  end
end
