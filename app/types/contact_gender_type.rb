class ContactGenderType < ActiveModel::Type::Value
  def cast(value)
    Nomis::Contact::Gender.new(value).freeze
  end
end
