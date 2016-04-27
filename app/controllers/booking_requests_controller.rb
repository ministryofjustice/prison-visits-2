class BookingRequestsController < ApplicationController
  helper FormElementsHelper

  def index
    processor = StepsProcessor.new(steps_params, I18n.locale)
    @steps = processor.steps
    @step_name = processor.step_name
    append_to_log booking_step_rendered: processor.step_name

    respond_to do |format|
      format.html { render processor.step_name }
    end
  end

  def create
    processor = StepsProcessor.new(steps_params, I18n.locale)
    @visit = processor.execute!
    @steps = processor.steps
    @step_name = processor.step_name
    append_to_log booking_step_rendered: processor.step_name
    append_to_log visit_id: @visit.id if @visit

    respond_to do |format|
      format.html { render processor.step_name }
    end
  end

private

  # It is not straight forward to whitelist parameters because the
  # 'date_of_birth' values can be a String or a Hash depending on the step.
  def steps_params
    permitted_fields = permit_prisoner_step +
                       permit_visitors_step +
                       permit_slots_step +
                       permit_review_step +
                       permit_confirmation_step

    params.permit(permitted_fields)
  end

  def permit_prisoner_step
    prisoner_step_attrs = params.fetch(:prisoner_step, {})

    person_attrs = permitted_person_attrs(prisoner_step_attrs)
    [prisoner_step:  person_attrs + [:number, :prison_id]]
  end

  def permit_visitors_step
    visitors_step = params.fetch(:visitors_step, {})
    # Any visitor would do here as all the visitors use the same type for their
    # date of birth.
    first_visitor = visitors_step.fetch(:visitors_attributes, {}).fetch('0', {})
    [visitors_step: [
      :email_address,
      :phone_no,
      :additional_visitor_count,
      visitors_attributes: permitted_person_attrs(first_visitor)]
    ]
  end

  def permit_slots_step
    [slots_step: [:option_0, :option_1, :option_2]]
  end

  def permit_review_step
    [:review_step]
  end

  def permit_confirmation_step
    [confirmation_step: [:confirmed]]
  end

  def permitted_person_attrs(hash = {})
    person_attrs = [:first_name, :last_name]

    if hash[:date_of_birth].is_a?(String)
      person_attrs + [:date_of_birth]
    else
      person_attrs + [date_of_birth: [:year, :month, :day]]
    end
  end

  def prison
    @steps.fetch(:prisoner_step).prison
  end
  helper_method :prison

  def reviewing?
    params.key?(:review_step)
  end
  helper_method :reviewing?
end
