class VisitDecorator < Draper::Decorator
  delegate_all
  decorates_association :rejection

  delegate :prisoner_availability_unknown?,
    :slot_availability_unknown?,
    :slots_unavailable?,
    :contact_list_unknown?,
    :prisoner_restrictions_unknown?,
    :prisoner,
    to: :nomis_checker

  delegate :prisoner_existance_status,
    :prisoner_existance_error,
    :details_incorrect?,
    to: :prisoner_details

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
                       object.build_rejection.decorate.tap(&:apply_nomis_reasons)
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
    prisoner.nomis_offender_id if Nomis::Api.enabled?
  end

  def bookable?
    slots.any?(&:bookable?) &&
      contact_list_working? &&
      principal_visitor.exact_match? &&
      !principal_visitor.banned?
  end

  def prisoner_restrictions
    @prisoner_restrictions ||=
      PrisonerRestrictionDecorator.decorate_collection(
        nomis_checker.prisoner_restrictions)
  end

  def offender_iep_level
    prisoner.iep_level
  end

  def offender_sentence_status
    prisoner.imprisonment_status
  end

private

  def last_visit_state_change
    object.visit_state_changes.max_by(&:created_at)
  end

  def nomis_checker
    h.nomis_checker
  end

  def prisoner_details
    h.prisoner_details
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
    @contact_list_working ||= !contact_list_unknown?
  end
end
