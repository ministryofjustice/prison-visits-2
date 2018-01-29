class AgeValidator < ActiveModel::EachValidator
  MAX_AGE = 120

  def validate_each(record, attribute, value)
    if value.present?
      check_is_date(record, attribute, value) &&
        check_range(record, attribute, value)
    end
  end

private

  def check_is_date(record, attribute, value)
    return true if value.to_date.is_a?(Date)

    add_invalid_error(record, attribute)
    false
  rescue ArgumentError
    add_invalid_error(record, attribute)
    false
  end

  def check_range(record, attribute, value)
    if value.to_date < minimum_date_of_birth
      record.errors.add(
        attribute,
        options[:message] ||
          I18n.t('age_validator.errors.range', max: MAX_AGE)
      )
    end
  end

  def minimum_date_of_birth
    MAX_AGE.years.ago.beginning_of_year.to_date
  end

  def add_invalid_error(record, attribute)
    record.errors.add(
      attribute,
      I18n.t('age_validator.errors.invalid_date')
    )
  end
end
