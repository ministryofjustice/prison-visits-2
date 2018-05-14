class PrisonerNumberType < ActiveModel::Type::String
  def cast(value)
    super(value&.strip&.upcase)
  end
end
