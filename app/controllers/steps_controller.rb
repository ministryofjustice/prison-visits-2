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
    @prisoner_step, incomplete = load_step(PrisonerStep)
    incomplete
  end

  def visitors_step
    @visitors_step, incomplete = load_step(VisitorsStep)
    incomplete
  end

  def slots_step
    @slots_step, incomplete = load_step(SlotsStep, prison: prison)
    incomplete
  end

  def confirmation_step
    @confirmation_step, incomplete = load_step(ConfirmationStep)
    incomplete
  end

  def load_step(klass, additional_params = {})
    name = klass.model_name.param_key
    if params.key?(name)
      step = klass.new(params[name].merge(additional_params))
      incomplete = step.invalid?
    else
      step = klass.new(additional_params)
      incomplete = true
    end

    [step, incomplete]
  end

  def prison
    Prison.find(params.fetch(:prisoner_step).fetch(:prison_id))
  end
end
