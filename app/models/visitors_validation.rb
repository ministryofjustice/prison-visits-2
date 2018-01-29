class VisitorsValidation
  include MemoryModel

  attribute :lead_date_of_birth, :date
  attribute :dates_of_birth
  attribute :prison, :prison

  validate :lead_visitor_age
  validate :number_of_visitors
  validate :number_of_adults

  def lead_visitor_age
    if age_calculator.age(lead_date_of_birth) < Prison::LEAD_VISITOR_MIN_AGE
      errors.add(:general, 'lead_visitor_age')
    end
  end

  def number_of_visitors
    if dates_of_birth.size > Prison::MAX_VISITORS
      errors.add(:general, 'too_many_visitors')
    end
  end

  def number_of_adults
    adults = dates_of_birth.select { |dob| considered_as_adult?(dob) }

    if adults.size > Prison::MAX_ADULTS
      errors.add(:general, 'too_many_adults')
    end
  end

  def error_keys
    errors[:general]
  end

private

  def age_calculator
    AgeCalculator.new
  end

  def considered_as_adult?(dob)
    age_calculator.age(dob) >= prison.adult_age
  end
end
