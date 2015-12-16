class ZendeskTicketsJob < ActiveJob::Base
  queue_as :zendesk

  # Custom ticket fields configured in the MOJ Digital Zendesk account
  URL_FIELD = '23730083'
  SERVICE_FIELD = '23757677'
  BROWSER_FIELD = '23791776'

  def perform(feedback)
    ZendeskAPI::Ticket.create!(
      Rails.configuration.zendesk_client,
      description: feedback.body,
      requester: {
        email: feedback.email_address,
        name: 'Unknown'
      },
      custom_fields: custom_fields(feedback)
    )
  end

  def custom_fields(feedback)
    [
      { id: URL_FIELD, value: feedback.referrer },
      { id: SERVICE_FIELD, value: 'prison_visits' },
      { id: BROWSER_FIELD, value: feedback.user_agent }
    ]
  end
end
