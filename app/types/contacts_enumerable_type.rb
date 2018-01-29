class ContactsEnumerableType < ActiveModel::Type::Value
  def cast(value)
    contacts = value.map { |contact| ContactType.new.cast(contact) }

    ContactsEnumerable.new(contacts)
  end
end
