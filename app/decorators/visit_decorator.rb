class VisitDecorator < Draper::Decorator
  delegate_all
  decorates_association :rejection

  delegate :prisoner_existance_status,
    :prisoner_existance_error,
    to: :nomis_checker

  def prisoner_details_incorrect
    (
      rejection &&
      rejection.reasons.include?(Rejection::PRISONER_DETAILS_INCORRECT)
    ) || prisoner_existance_status == StaffNomisChecker::INVALID
  end

  def slots
    @slots ||= object.slots.map.with_index { |slot, i|
      ConcreteSlotDecorator.decorate(
        slot,
        context: { index: i, nomis_checker: nomis_checker }
      )
    }
  end

  def rejection
    @rejection ||= (object.rejection || object.build_rejection).decorate
  end

  def principal_visitor
    @principal_visitor ||= object.principal_visitor.decorate
  end

  def additional_visitors
    @additional_visitors ||= VisitorDecorator.
                             decorate_collection(object.additional_visitors)
  end

private

  def nomis_checker
    @nomis_checker ||= StaffNomisChecker.new(object)
  end
end
