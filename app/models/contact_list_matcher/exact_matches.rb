class ContactListMatcher::ExactMatches
  include ContactListMatcherBehaviour

  def contact_id
    contact&.id
  end

  def contact
    contacts&.first
  end
end
