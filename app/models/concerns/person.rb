module Person
  extend ActiveSupport::Concern

  MAX_AGE = 120

  included do
    validates :first_name, presence: true, name: true
    validates :last_name, presence: true, name: true
    validates :date_of_birth, presence: true, age: true
  end

  def full_name
    I18n.t('formats.name.full', first: first_name, last: last_name)
  end

  def anonymized_name
    I18n.t('formats.name.full', first: first_name, last: last_name[0])
  end

  def age
    return nil unless date_of_birth

    AgeCalculator.new.age(date_of_birth)
  end

  def valid_person?
    valid?

    %i[first_name last_name date_of_birth].all? do |key|
      errors[key].empty?
    end
  end
end
