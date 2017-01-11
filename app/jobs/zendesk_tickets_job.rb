# frozen_string_literal: true
class ZendeskTicketsJob < ActiveJob::Base
  queue_as :zendesk

  # Custom ticket fields configured in the MOJ Digital Zendesk account
  URL_FIELD = '23730083'
  SERVICE_FIELD = '23757677'
  BROWSER_FIELD = '23791776'
  PRISON_FIELD = '23984153'

  def perform(feedback)
    unless Rails.configuration.try(:zendesk_client)
      fail 'Cannot create Zendesk ticket since Zendesk not configured'
    end

    ZendeskAPI::Ticket.create!(
      Rails.configuration.zendesk_client,
      ticket_attrs(feedback)
    )
  end

private

  # We have 2 Zendesk inboxes configured, one for the public that matches that
  # the service field is 'prison_visits' and another one for staff that matches
  # tickets tagged with 'staff.prison.visits'.
  def ticket_attrs(feedback)
    attrs = {
      description: feedback.body,
      requester: { email: email_address_to_submit(feedback), name: 'Unknown' }
    }

    if feedback.submitted_by_staff
      attrs.merge(staff_attrs(feedback))
    else
      attrs.merge(public_attrs(feedback))
    end
  end

  def staff_attrs(feedback)
    {
      tags: ['staff.prison.visits'],
      custom_fields: staff_custom_fields(feedback)
    }
  end

  def public_attrs(feedback)
    { custom_fields: public_custom_fields(feedback) }
  end

  # Zendesk requires tickets to have an email, but we do not enforce
  # providing an email. Therefore, a default email is used.
  def email_address_to_submit(feedback)
    if feedback.email_address.present?
      feedback.email_address
    else
      Rails.configuration.address_book.feedback
    end
  end

  def staff_custom_fields(feedback)
    attrs = [
      { id: URL_FIELD, value: feedback.referrer },
      { id: BROWSER_FIELD, value: feedback.user_agent }
    ]

    if feedback.prison_id
      attrs << { id: PRISON_FIELD, value: feedback.prison.name }
    end

    attrs
  end

  def public_custom_fields(feedback)
    service_field = { id: SERVICE_FIELD, value: 'prison_visits' }
    staff_custom_fields(feedback) << service_field
  end
end
