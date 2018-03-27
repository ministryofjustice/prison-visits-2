class StaffInfoController < ApplicationController
  include PrisonRestriction

  def show
    prison_ids = accessible_estates.map(&:id)
    @prisons = Prison.where(estate_id: prison_ids).order(:name)
    @days = %w[mon tue wed thu fri sat sun]
    @day_names = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
  end

  private
  def format_slot(slot)
    slot[0...2]+":"+slot[2...4]+" - "+slot[5...7]+":"+slot[7...9]
  end
  helper_method :format_slot
end
