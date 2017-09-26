class VisitorDecorator < Draper::Decorator
  delegate_all

  NO_VISITORS_IN_NOMIS = 'no_visitor_in_nomis'.freeze

  # rubocop:disable Metrics/MethodLength
  def contact_list(form_build, contact_list)
    contact_list         = Nomis::ContactDecorator.decorate_collection(contact_list)
    contact_list_matcher = ContactListMatcher.new(contact_list, object)
    exact_matches        = contact_list_matcher.exact_matches
    selected_noms_id     = exact_matches.contact_id

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
          selected: selected_noms_id, disabled: ['']
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
