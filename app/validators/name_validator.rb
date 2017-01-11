# frozen_string_literal: true
class NameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    if value.length > 30 || value.include?('<') || value.include?('>')
      record.errors.add attribute, :name
    end
  end
end
