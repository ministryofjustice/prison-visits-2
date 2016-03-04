class SendgridApi
  class Error < StandardError; end

  def initialize
    @connection = Excon.new(Rails.configuration.sendgrid_api_host,
      persistent: true)
  end

  def spam_reported?(email)
    route = 'spamreports.get.json'
    query = { email: email }

    response = get_request(route, query)

    response.any?
  rescue => e
    Rails.logger.error("SendgridApi error: #{e.class} #{e}")
    false
  end

  def bounced?(email)
    route = 'bounces.get.json'
    query = { email: email }

    response = get_request(route, query)

    response.any?
  rescue => e
    Rails.logger.error("SendgridApi error: #{e.class} #{e}")
    false
  end

  def remove_from_bounce_list(email)
    route = 'bounces.delete.json'
    body = { email: email }

    response = post_request(route, body)

    check_email_error(response)
  rescue => e
    Rails.logger.error("SendgridApi error: #{e.class} #{e}")
  end

  def remove_from_spam_list(email)
    route = 'spamreports.delete.json'
    body = { email: email }

    response = post_request(route, body)

    check_email_error(response)
  rescue => e
    Rails.logger.error("SendgridApi error: #{e.class} #{e}")
  end

private

  def credentials
    if Rails.configuration.sendgrid_api_user.blank? ||
       Rails.configuration.sendgrid_api_key.blank?
      fail Error, 'no api credentials specified'
    end

    {
      api_user: Rails.configuration.sendgrid_api_user,
      api_key: Rails.configuration.sendgrid_api_key
    }
  end

  # rubocop:disable Metrics/MethodLength
  def get_request(route, query)
    options = {
      path: "api/#{route}",
      expects: [200],
      headers: {
        'Accept' => 'application/json',
        'Accept-Language' => 'en'
      },
      query: query.merge(credentials)
    }

    response = JSON.parse(@connection.get(options).body)

    check_for_error(response)

    response
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def post_request(route, body)
    options = {
      path: "/api/#{route}",
      expects: [200],
      headers: {
        'Accept' => 'application/json',
        'Accept-Language' => 'en'
      },
      query: URI.encode_www_form(body.merge(credentials))
    }

    response = JSON.parse(@connection.post(options).body)

    check_for_error(response)

    response
  end
  # rubocop:enable Metrics/MethodLength

  def check_for_error(response)
    # Response could be empty which gets translated to an Array or have data
    # which becomes a Hash according to the specs
    if response.try(:key?, 'error')
      fail Error, "responsed: #{response['error']}"
    end
  end

  def check_email_error(response)
    if response.try(:key?, 'message')
      fail Error, "email does not exist: #{response['message']}"
    end
  end
end
