class VisitorDecorator < Draper::Decorator
  delegate_all

  NO_VISITORS_IN_NOMIS = 'no_visitor_in_nomis'.freeze
  def contact_list_matching(form_build)
    return I18n.t(".#{NO_VISITORS_IN_NOMIS}") unless contact_list_matcher.any?

    h.render 'prison/visits/contact_list', vf: form_build, matched: exact_matches.any? do
      form_build.select(
        :nomis_id,
        h.option_groups_from_collection_for_select(
          contact_list_matcher.matches,
          :contacts_with_data,
          :category,
          ->(contact) { contact.first.id  },
          ->(contact) { contact.first.full_name_and_dob },
          selected: exact_matches.contact_id, disabled: ['']),
        { prompt: I18n.t('.please_select', scope: %i[prison visits visitor_contact]) },
        class: 'form-control js-contactList'
      )
    end
  end

  def exact_match?
    exact_matches.contact.present?
  end

  def banned?
    exact_matches.contact.banned?
  end

private

  def contact_list_matcher
    @contact_list_matcher ||= ContactListMatcher.new(contact_list, object)
  end

  def exact_matches
    contact_list_matcher.exact_matches
  end

  def contact_list
    context[:contact_list]
  end
end
