class ContactsEnumerableType < ActiveModel::Type::Value
  def cast(value)
    contacts = value.map { |contact| type_caster.cast(contact) }
    contacts.dup.sort.freeze
  end

private

  def type_caster
    @type_caster ||= ContactType.new
  end
end
