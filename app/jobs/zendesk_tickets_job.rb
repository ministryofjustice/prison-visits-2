class ZendeskTicketsJob < ActiveJob::Base
  queue_as :zendesk

  # Custom ticket fields configured in the MOJ Digital Zendesk account
  URL_FIELD = '23730083'
  SERVICE_FIELD = '23757677'
  BROWSER_FIELD = '23791776'

  # rubocop:disable Metrics/MethodLength
  def perform(feedback)
    unless Rails.configuration.zendesk_client
      fail 'Cannot create Zendesk ticket since Zendesk not configured'
    end

    ZendeskAPI::Ticket.create!(
      Rails.configuration.zendesk_client,
      description: feedback.body,
      requester: {
        email: email_address_to_submit(feedback),
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

private

  # Zendesk requires tickets to have an email, but we do not enforce
  # providing an email. Therefore, a default email is used.
  def email_address_to_submit(feedback)
    if feedback.email_address.present?
      feedback.email_address
    else
      Rails.configuration.address_book.feedback
    end
  end
end
