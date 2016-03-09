class SendgridApi
  RESCUABLE_ERRORS = [JSON::ParserError,
                      Excon::Errors::Error,
                      Timeout::Error
                     ].freeze

  def initialize(api_user:, api_key:, timeout:)
    @api_user = api_user
    @api_key = api_key
    @timeout = timeout
  end

  def configure_pool(pool_size:, pool_timeout:)
    @pool = ConnectionPool.new(size: pool_size, timeout: pool_timeout) do
      SendgridClient.new(
        api_key: @api_key,
        api_user: @api_user,
        http_opts: { persistent: true, timeout: @timeout })
    end
  end

  def spam_reported?(email)
    action = 'spamreports.get.json'
    query = { email: email }

    call_api(:post, action, query) { |response|
      !error_response?(response) && response.any?
    }
  end

  def bounced?(email)
    action = 'bounces.get.json'
    query = { email: email }

    call_api(:post, action, query) { |response|
      !error_response?(response) && response.any?
    }
  end

  def remove_from_bounce_list(email)
    action = 'bounces.delete.json'
    data = { email: email }

    call_api(:post, action, data) { |response|
      !error_response?(response) && email_removed?(response)
    }
  end

  def remove_from_spam_list(email)
    action = 'spamreports.delete.json'
    data = { email: email }

    call_api(:post, action, data) { |response|
      !error_response?(response) && email_removed?(response)
    }
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
    if response['message'] == 'success'
      true
    else
      msg = "'#{self.class.name}' #{response['message']}"
      Rails.logger.error(msg)
      false
    end
  end

  def call_api(method, action, data)
    unless enabled?
      Rails.logger.error('Sendgrid is disabled')
      return false
    end

    response = @pool.with { |client| client.request(method, action, data) }

    yield response
  rescue => e
    Rails.logger.error("#{e.class.name}: #{e.message}")
    Raven.capture_exception(e) unless RESCUABLE_ERRORS.include?(e.class)
    false
  end

  def enabled?
    @pool.present?
  end
end
