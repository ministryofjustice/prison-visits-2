module Api
  class FeedbackController < ApiController
    def create
      @feedback = FeedbackSubmission.create!(feedback_params)
      ZendeskTicketsJob.perform_later(@feedback)
      render json: {}, status: 200
    end

  private

    def feedback_params
      params.
        require(:feedback).
        permit(:referrer, :body, :email_address, :user_agent)
    end
  end
end
