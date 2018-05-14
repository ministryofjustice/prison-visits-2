class ContactTypeType < ActiveModel::Type::Value
  def cast(value)
    Nomis::Contact::ContactType.new(value).freeze
  end
end
