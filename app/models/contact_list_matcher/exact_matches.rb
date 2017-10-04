class ContactListMatcher::ExactMatches
  include ContactListMatcherBehaviour

  def contact_id
    return unless any?
    contacts.first.id
  end
end
