# frozen_string_literal: true

class UnbookableDatesController < ApplicationController
  before_action :load_prison

  def new
    @unbookable_date = @prison.unbookable_dates.new
  end

  def create
    @unbookable_date = @prison.unbookable_dates.create(date_params)
    if @unbookable_date.persisted?
      redirect_to prison_path(locale, @prison)
    else
      render 'new'
    end
  end

  def destroy
    @prison.unbookable_dates.detect { |d| d.date.to_s == params[:date] }.destroy
    redirect_to prison_path(locale, @prison)
  end

private

  def locale
    params[:locale]
  end

  def load_prison
    @prison = Prison.find(params[:prison_id])
  end

  def date_params
    params.require(:unbookable_date).permit(:date_dd, :date_mm, :date_yyyy)
  end
end
