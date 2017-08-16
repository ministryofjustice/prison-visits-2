class VisitorDecorator < Draper::Decorator
  delegate_all

  NO_VISITORS_IN_NOMIS = 'no_visitor_in_nomis'.freeze

  # rubocop:disable Metrics/MethodLength
  def contact_list(form_build, contact_list)
    contact_list         = Nomis::ContactDecorator.decorate_collection(contact_list)
    contact_list_matcher = ContactListMatcher.new(contact_list, object)
    matched              = !contact_list_matcher.exact_matches.empty?
    if matched
      selected_noms_id = contact_list_matcher.exact_matches.contacts.first.id
    end

    return I18n.t(".#{NO_VISITORS_IN_NOMIS}") if contact_list_matcher.empty?

    h.render 'prison/visits/contact_list', vf: form_build, matched: matched do
      form_build.select(
        :nomis_id,
        h.option_groups_from_collection_for_select(
          contact_list_matcher.matches,
          :contacts_with_data,
          :category,
          ->(contact) { contact.first.id  },
          ->(contact) { contact.first.full_name_and_dob },
          selected: selected_noms_id
        ),
        { prompt: I18n.t(
          '.please_select', scope: [
              :prison, :visits, :visitor_contact])
        },
        class: 'form-control js-contactList'
      )
    end
  end
  # rubocop:enable Metrics/MethodLength
end
