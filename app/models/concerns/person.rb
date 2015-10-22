module Person
  extend ActiveSupport::Concern

  MAX_AGE = 120

  included do
    attribute :first_name, String
    attribute :last_name, String
    attribute :date_of_birth, Date

    validates :first_name, presence: true, name: true
    validates :last_name, presence: true, name: true
    validates :date_of_birth,
      presence: true,
      inclusion: {
        in: ->(p) { p.minimum_date_of_birth..p.maximum_date_of_birth }
      }
    validate :validate_four_digit_year
  end

  def full_name(glue = ' ')
    [first_name, last_name].join(glue)
  end

  def last_initial
    last_name.chars.first.upcase
  end

  def age
    return nil unless date_of_birth
    AgeCalculator.new.age(date_of_birth)
  end

  def minimum_date_of_birth
    MAX_AGE.years.ago.beginning_of_year.to_date
  end

  def maximum_date_of_birth
    Time.zone.today.end_of_year
  end

  def date_of_birth
    super.is_a?(Date) ? super : nil
  end

private

  def validate_four_digit_year
    if date_of_birth.respond_to?(:year) && date_of_birth.year < 100
      errors.add :date_of_birth, :four_digit_year
    end
  end
end
