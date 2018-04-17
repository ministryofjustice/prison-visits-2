class ContactRelationshipType < ActiveModel::Type::Value
  def cast(value)
    Nomis::Contact::Relationship.new(value).freeze
  end
end
