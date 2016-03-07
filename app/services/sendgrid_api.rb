class SendgridApi
  TIMEOUT = 2 # seconds

  RESCUABLE_ERRORS = [SendgridClient::Error,
                      JSON::ParserError,
                      Excon::Errors::Error].freeze

  def spam_reported?(email)
    action = 'spamreports.get.json'
    query = { email: email }

    response = SendgridClient.instance.get_request(action, query)

    return false if error_response?(response)

    response.any?
  rescue *RESCUABLE_ERRORS => e
    Rails.logger.error("#{e.class.name}: #{e.message}")
    false
  end

  def bounced?(email)
    action = 'bounces.get.json'
    query = { email: email }

    response = SendgridClient.instance.get_request(action, query)

    return false if error_response?(response)

    response.any?
  rescue *RESCUABLE_ERRORS => e
    Rails.logger.error("#{e.class.name}: #{e.message}")
    false
  end

  def remove_from_bounce_list(email)
    action = 'bounces.delete.json'
    data = { email: email }

    response = SendgridClient.instance.post_request(action, data)

    return false if error_response?(response)

    email_removed?(response)
  rescue *RESCUABLE_ERRORS => e
    Rails.logger.error("#{e.class.name}: #{e.message}")
    false
  end

  def remove_from_spam_list(email)
    action = 'spamreports.delete.json'
    data = { email: email }

    response = SendgridClient.instance.post_request(action, data)

    return false if error_response?(response)

    email_removed?(response)
  rescue *RESCUABLE_ERRORS => e
    Rails.logger.error("#{e.class.name}: #{e.message}")
    false
  end

private

  def error_response?(response)
    # Response could be empty which gets translated to an Array or have data
    # which becomes a Hash according to the specs
    if response.try(:key?, 'error')
      msg = "'#{self.class.name}' sendgrid response: #{response['error']}"
      Rails.logger.error(msg)
      true
    else
      false
    end
  end

  def email_removed?(response)
    if response.try(:key?, 'message') && response['message'] != 'success'
      msg = "'#{self.class.name}' #{response['message']}"
      Rails.logger.error(msg)
      false
    else
      true
    end
  end
end
