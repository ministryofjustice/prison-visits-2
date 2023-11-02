class Prison::MessagesController < ApplicationController
  include StaffResponseContext

  before_action :authenticate_user

  def create
    @message = Message.create_and_send_email(message_params)

    if @message.persisted?
      flash[:notice] = t('message_created', scope: %i[prison flash])
      redirect_to prison_visit_path(memoised_visit)
    else
      @visit = memoised_visit.decorate
      flash[:notice] = t('message_create_error', scope: %i[prison flash])
      render 'prison/visits/show'
    end
  end

private

  def message_params
    params.require(:message).permit(:body)
      .merge(user: current_user, visit: memoised_visit)
  end
end
