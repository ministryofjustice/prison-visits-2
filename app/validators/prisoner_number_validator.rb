class PrisonerNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.match?(/\A[a-z]\d{4}[a-z]{2}\z/i)
      record.errors.add(attribute,
                        I18n.t('prisoner_number_validator.errors.format'))
    end
  end
end
