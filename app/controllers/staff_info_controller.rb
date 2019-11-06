class StaffInfoController < ApplicationController
  include PrisonRestriction
  before_action :authorize_prison_request
  before_action :authenticate_user
  DAY_NAMES = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]

  def show
    prison_ids = accessible_estates.map(&:id)
    @prisons = Prison.where(estate_id: prison_ids).order(:name)
  end
end
