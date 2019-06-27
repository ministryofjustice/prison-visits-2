module Api
  class FeedbackController < ApiController
    def create
      @feedback = FeedbackSubmission.create!(feedback_params)
      ZendeskTicketsJob.perform_later(@feedback)
      render json: {}, status: :ok
    end

  private

    def feedback_params
      params.
        require(:feedback).
        permit(:referrer, :body, :email_address, :user_agent, :prison_id,
               :prisoner_number, :prisoner_date_of_birth).
        merge(submitted_by_staff: false)
    end
  end
end
