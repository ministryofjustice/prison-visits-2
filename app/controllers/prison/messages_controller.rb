class Prison::MessagesController < ApplicationController
  before_action :authorize_prison_request
  before_action :authenticate_user

  def create
    load_visit
    @message = Message.create_and_send_email(message_params)

    if @message.persisted?
      flash[:notice] = t('message_created', scope: [:prison, :flash])
      redirect_to :back
    else
      flash[:notice] = t('message_create_error', scope: [:prison, :flash])
      render 'prison/visits/show'
    end
  end

private

  def load_visit
    @visit ||= Visit.joins(prison: :estate).
               where(estates: { id: current_estate }).
               find(params[:visit_id])
  end
  alias_method :visit, :load_visit

  def message_params
    params.require(:message).permit(:body).
      merge(user: current_user, visit: visit)
  end
end
