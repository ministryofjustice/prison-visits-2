class ZendeskTicketsJob < ActiveJob::Base
  queue_as :zendesk

  # Custom ticket field IDs as configured in the MOJ Digital Zendesk account
  URL_FIELD = '23730083'.freeze
  SERVICE_FIELD = '23757677'.freeze
  BROWSER_FIELD = '23791776'.freeze
  PRISON_FIELD = '23984153'.freeze
  PRISONER_NUM_FIELD = '114094604912'.freeze
  PRISONER_DOB_FIELD = '114094604972'.freeze

  def perform(feedback)
    feedback.destroy! if ticket_raised!(feedback)
  end

private

  # We have 2 Zendesk inboxes configured, one for the public that matches that
  # the service field is 'prison_visits' and another one for staff that matches
  # tickets tagged with 'staff.prison.visits'.

  def ticket_raised!(feedback)
    client = Zendesk::PVBClient.instance
    Zendesk::PVBApi.new(client).raise_ticket(**ticket_attrs(feedback))
  end

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
    feedback.email_address.presence || Rails.configuration.address_book.feedback
  end

  def staff_custom_fields(feedback)
    attrs = [
      as_hash(URL_FIELD, feedback.referrer),
      as_hash(BROWSER_FIELD, feedback.user_agent)
    ]

    if feedback.prison_id
      attrs << as_hash(PRISON_FIELD, feedback.prison.name)
    end

    attrs
  end

  def public_custom_fields(feedback)
    fields = staff_custom_fields(feedback)
    fields << as_hash(SERVICE_FIELD, 'prison_visits')

    if feedback.prisoner_number
      fields << as_hash(PRISONER_NUM_FIELD, feedback.prisoner_number)
    end

    if feedback.prisoner_date_of_birth
      fields << as_hash(PRISONER_DOB_FIELD, feedback.prisoner_date_of_birth)
    end

    fields
  end

  def as_hash(id, value)
    { id:, value: }
  end
end
