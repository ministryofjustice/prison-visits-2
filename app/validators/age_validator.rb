class AgeValidator < ActiveModel::EachValidator
  MAX_AGE = 120

  def validate_each(record, attribute, value)
    check_range(record, attribute, value) if value.present?
  end

private

  def check_range(record, attribute, value)
    if value < minimum_date_of_birth
      record.errors.add(attribute,
        I18n.t('age_validator.errors.range', max: MAX_AGE))
    end
  end

  def minimum_date_of_birth
    MAX_AGE.years.ago.beginning_of_year.to_date
  end
end
