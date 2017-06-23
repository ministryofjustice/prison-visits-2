class VisitDecorator < Draper::Decorator
  delegate_all
  decorates_association :rejection
  NO_VISITORS_IN_NOMIS = 'no_visitor_in_nomis'.freeze

  delegate :prisoner_existance_status,
    :prisoner_existance_error,
    :prisoner_availability_unknown?,
    :slot_availability_unknown?,
    :slots_unavailable?,
    :contact_list_unknown?,
    :approved_contacts,
    to: :nomis_checker

  def slots
    @slots ||= object.slots.map.with_index { |slot, i|
      ConcreteSlotDecorator.decorate(
        slot,
        context: { index: i, visit: object, nomis_checker: nomis_checker }
      )
    }
  end

  def rejection
    @rejection ||= begin
                     if object.rejection
                       object.rejection.decorate
                     else
                       object.build_rejection.decorate.tap do |rej|
                         rej.apply_nomis_reasons(nomis_checker)
                       end
                     end
                   end
  end

  def principal_visitor
    @principal_visitor ||= object.principal_visitor.decorate
  end

  def additional_visitors
    @additional_visitors ||= VisitorDecorator.
                               decorate_collection(object.additional_visitors)
  end

  def processed_at
    @processed_at ||= last_visit_state_change&.created_at || object.created_at
  end

  def contact_list(visitor_form_builder, selected_noms_id)
    return I18n.t(".#{NO_VISITORS_IN_NOMIS}") if approved_contacts.empty?
    visitor_form_builder.select(
      :nomis_id, options_for_contact_list(selected_noms_id),
      {
        prompt: I18n.t(
          '.please_select', scope: [
            :prison, :visits, :visitor_contact])
      },
      class: 'form-control js-contactList')
  end

private

  def options_for_contact_list(selected_noms_id)
    h.options_for_select(
      Nomis::ContactDecorator.decorate_collection(approved_contacts).map { |contact|
        [
          contact.full_name_and_dob,
          contact.id,
          data: { contact: contact.to_data_attributes }
        ]
      },
      selected_noms_id
    )
  end

  def last_visit_state_change
    object.visit_state_changes.max_by(&:created_at)
  end

  def nomis_checker
    context[:staff_nomis_checker]
  end
end
