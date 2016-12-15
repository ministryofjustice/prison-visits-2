class Prison::SwitchEstatesController < ApplicationController
  before_action :authorize_prison_request
  before_action :authenticate_user
  before_action :verify_switch_estates

  def create
    estates = Estate.where(id: params[:estates_id])
    if sso_identity.accessible_estates?(estates)
      @_current_estates         = nil
      session[:current_estates] = estates.map(&:id)
    else
      # This should never happen
      flash[:notice] = t('invalid_estate_selection', scope: [:prison, :flash])
    end
    redirect_to :back
  end

private

  def verify_switch_estates
    if params[:estates_id].nil? || params[:estates_id].empty?
      flash[:notice] = t('at_least_one_estate', scope: [:prison, :flash])
      redirect_to :back
    end
  end
end
