module Api
  class FeedbackSubmissionsController < ApiController
    def create
      @feedback = FeedbackSubmission.new(feedback_params)

      if @feedback.save
        ZendeskTicketsJob.perform_later(@feedback)
      else
        render status: 422, json: { messages: @feedback.errors.full_messages }
      end
    end

  private

    def feedback_params
      params.
        require(:feedback_submission).
        permit(:referrer, :body, :email_address, :user_agent)
    end
  end
end
