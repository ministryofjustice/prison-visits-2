class Prison::FeedbacksController < ApplicationController
  def new
    @feedback = FeedbackSubmission.new(email_address: current_user&.email)
  end

  def create
    @feedback = FeedbackSubmission.new(feedback_params)
    if @feedback.save
      ZendeskTicketsJob.perform_later(@feedback)
      redirect_to prison_inbox_path,
                  notice: t('feedback_submitted', scope: %i[prison flash])
    else
      render :new
    end
  end

private

  def feedback_params
    params.
      require(:feedback_submission).
      permit(:referrer, :body, :email_address, :user_agent, :prison_id).
      merge(submitted_by_staff: true)
  end
end
