# frozen_string_literal: true

class RecurringSlotsController < ApplicationController
  before_action :load_prison
  before_action :load_slot_day, only: [:edit, :update]

  def new
    @slot_day = @prison.slot_days.new day: params[:day]
  end

  def edit; end

  def create
    @slot_day = @prison.slot_days.create slot_day_params

    if @slot_day.persisted?
      redirect_to prison_path(params[:locale], @prison)
    else
      render 'new'
    end
  end

  def update
    if @slot_day.update(slot_day_params)
      redirect_to prison_path(params[:locale], @prison)
    else
      render 'edit'
    end
  end

private

  def load_slot_day
    @slot_day = @prison.slot_days.where(day: params[:day]).first!
  end

  def slot_day_params
    params.require(:slot_day).permit(:day,
                                     :start_date_dd, :start_date_mm, :start_date_yyyy,
                                     :end_date_dd, :end_date_mm, :end_date_yyyy)
  end

  def load_prison
    @prison = Prison.find(params[:prison_id])
  end
end
