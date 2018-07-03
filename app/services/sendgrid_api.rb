class SendgridApi
  RESCUABLE_ERRORS = [JSON::ParserError,
                      Excon::Errors::Error,
                      Timeout::Error
                     ].freeze

  class << self
    def instance
      @instance ||= begin
        pool_size = database_pool_size

        client = new_client(Rails.configuration.sendgrid_api_user,
          Rails.configuration.sendgrid_api_key)

        pool = ConnectionPool.new(size: pool_size, timeout: 1, &client)
        send(:new, pool)
      end
    end

    def new_client(api_user, api_key)
      lambda {
        SendgridClient.new(
          api_key: api_key,
          api_user: api_user,
          http_opts: { persistent: true, timeout: 2 }
        )
      }
    end

  private

    def database_pool_size
      db_config = Rails.configuration.database_configuration
      db_config[Rails.env].fetch('pool', 5)
    end
  end

  def spam_reported?(email)
    action = 'spamreports.get.json'
    query = { email: email }

    call_api(:post, action, query) { |response| email_found?(response) }
  end

  def bounced?(email)
    action = 'bounces.get.json'
    query = { email: email }

    call_api(:post, action, query) { |response| email_found?(response) }
  end

  def remove_from_bounce_list(email)
    action = 'bounces.delete.json'
    data = { email: email }

    call_api(:post, action, data) { |response| email_removed?(response) }
  end

  def remove_from_spam_list(email)
    action = 'spamreports.delete.json'
    data = { email: email }

    call_api(:post, action, data) { |response| email_removed?(response) }
  end

  def delete_spam_list
    action = 'spamreports.delete.json'
    data = { delete_all: 1 }

    call_api(:post, action, data) { |response| email_removed?(response) }
  end

  def disable
    @enabled = false
  end

private

  def initialize(pool)
    @pool = pool
    @enabled = true
  end

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
    return false if error_response?(response)

    if response['message'] == 'success'
      true
    else
      msg = "'#{self.class.name}' #{response['message']}"
      Rails.logger.error(msg)
      false
    end
  end

  def email_found?(response)
    return false if error_response?(response)

    response.any?
  end

  def call_api(method, action, data)
    return false unless enabled?

    response = @pool.with { |client| client.request(method, action, data) }

    yield response
  rescue StandardError => e
    Rails.logger.error("#{e.class.name}: #{e.message}")
    PVB::ExceptionHandler.capture_exception(e) unless ignore_error?(e)
    false
  end

  def ignore_error?(error)
    RESCUABLE_ERRORS.any? { |error_klass| error.is_a?(error_klass) }
  end

  def enabled?
    @enabled
  end
end
