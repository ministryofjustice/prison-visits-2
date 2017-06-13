class LeadVisitor < Visitor
  ADULT_AGE = 18

  belongs_to :visit
  validate :adult?

private

  def adult?
    unless ADULT_AGE.years.ago > date_of_birth
      errors.add(:date_of_birth, :is_not_an_adult)
    end
  end
end
