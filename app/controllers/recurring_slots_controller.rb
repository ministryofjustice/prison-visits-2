# frozen_string_literal: true

class RecurringSlotsController < ApplicationController
  before_action :load_prison
  before_action :load_slot_day, only: [:edit, :update]

  def new; end

  def edit; end

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
    params.require(:slot_day).permit(:end_date_dd, :end_date_mm, :end_date_yyyy)
  end

  def load_prison
    @prison = Prison.find(params[:prison_id])
  end
end
