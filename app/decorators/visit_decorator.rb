class VisitDecorator < Draper::Decorator
  delegate_all
  decorates_association :rejection

  delegate :prisoner_existance_status,
    :prisoner_existance_error,
    :prisoner_availability_unknown?,
    :slot_availability_unknown?,
    :slots_unavailable?,
    :contact_list_unknown?,
    :prisoner_restrictions_unknown?,
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

  def cancellation
    @cancellation ||= (object.cancellation || build_cancellation).decorate
  end

  def principal_visitor
    @principal_visitor ||= object.principal_visitor.decorate(visitor_context)
  end

  def additional_visitors
    @additional_visitors ||=
      VisitorDecorator.decorate_collection(object.additional_visitors, visitor_context)
  end

  def processed_at
    @processed_at ||= last_visit_state_change&.created_at || object.created_at
  end

  def nomis_offender_id
    nomis_checker.offender.id if Nomis::Api.enabled?
  end

  def bookable?
    slots.any?(&:bookable?) &&
      contact_list_working? &&
      principal_visitor.exact_match? &&
      !principal_visitor.banned?
  end

private

  def last_visit_state_change
    object.visit_state_changes.max_by(&:created_at)
  end

  def nomis_checker
    context[:staff_nomis_checker]
  end

  def visitor_context
    if contact_list_working?
      { context: { contact_list: approved_contacts } }
    else
      {}
    end
  end

  def approved_contacts
    @approved_contacts ||=
      Nomis::ContactDecorator.decorate_collection(nomis_checker.approved_contacts)
  end

  def contact_list_working?
    @contact_list_working ||=
      Nomis::Feature.contact_list_enabled?(prison_name) && !contact_list_unknown?
  end
end
