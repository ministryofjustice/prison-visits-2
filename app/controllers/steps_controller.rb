class StepsController < ApplicationController
  helper FormElementsHelper

  def index
    @prisoner_step = PrisonerStep.new
    render :prisoner_step
  end

  def create
    render select_step
  end

private

  STEPS = %i[
    prisoner_step
    visitors_step
    slots_step
    confirmation_step
  ]

  def select_step
    STEPS.find { |s| send(s) } || complete
  end

  def complete
    BookingRequestCreator.new.create!(
      @prisoner_step,
      @visitors_step,
      @slots_step
    )
    :completed
  end

  def prisoner_step
    @prisoner_step, needed = load_step(PrisonerStep)
    needed
  end

  def visitors_step
    @visitors_step, needed = load_step(VisitorsStep)
    needed
  end

  def slots_step
    @slots_step, needed = load_step(SlotsStep, prison: @prisoner_step.prison)
    needed
  end

  def confirmation_step
    @confirmation_step, needed = load_step(ConfirmationStep)
    needed
  end

  def load_step(klass, additional_params = {})
    name = klass.model_name.param_key
    if params.key?(name)
      step = klass.new(params[name].merge(additional_params))
      needed = !step.valid?
    else
      step = klass.new(additional_params)
      needed = true
    end

    [step, needed]
  end
end
