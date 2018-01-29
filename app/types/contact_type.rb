class ContactType < ActiveModel::Type::Value
  def cast(value)
    if value.is_a?(Nomis::Contact)
      value
    else
      Nomis::Contact.new(value)
    end
  end
end
