class ContactsEnumerable
  include Enumerable

  delegate :each, to: :contacts

  def initialize(contacts = [])
    raise ArgumentError unless contacts.all? { |v| v.is_a?(Nomis::Contact) }

    self.contacts = contacts.dup.sort.freeze
  end

  def to_a
    contacts
  end

private

  attr_accessor :contacts
end
