class Prison::PrintVisitsController < ApplicationController
  before_action :authorize_prison_request
  before_action :authenticate_user

  def new
    @print_visits = ::PrintVisits.new
  end

  def show
    @print_visits = ::PrintVisits.new(permitted_visit_date_params)
    validate_visit_date
    @data = EstateVisitQuery.new(current_estates).visits_to_print_by_slot(@submitted_date)

    respond_to do |format|
      format.html
      format.csv do
        render csv: BookedVisitsCsvExporter.new(@data),
               filename: 'booked_visits'
      end
    end
  end

private

  def validate_visit_date
    @submitted_date = AccessibleDate.new(
      date_to_accessible_date(@print_visits.visit_date)
      ).to_date
    @print_visits.valid? unless @submitted_date.nil?
  end

  def date_to_accessible_date(date)
    return date if date.is_a?(Hash)

    {
      year:  date.year,
      month: date.month,
      day:   date.day
    }
  end

  def permitted_visit_date_params
    params.require(:print_visits).permit(visit_date: %i[day month year])
  end
end
