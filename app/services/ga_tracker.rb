class GATracker
  ENDPOINT = URI.parse('https://www.google-analytics.com/collect').freeze

  def initialize(user, visit, cookies, request)
    self.user            = user
    self.visit           = visit
    self.prison          = visit.prison
    self.cookies         = cookies
    self.request         = request
    self.web_property_id = Rails.application.config.ga_id
  end

  def set_visit_processing_time_cookie
    cookies[processing_time_key] ||= {
      value: Time.zone.now.to_i, expires: 1.week.from_now
    }
  end

  def send_event
    return unless value
    client.post(
      path:    ENDPOINT.path,
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
      body:    URI.encode_www_form(payload_data)
    )
    delete_visit_processing_time_cookie
  end

private

  attr_accessor :web_property_id, :user, :prison, :visit, :cookies, :request

  def client
    @client ||= Excon.new(ENDPOINT.to_s, persistent: true)
  end

  def value
    return unless start_time
    (Time.zone.now - start_time).to_i * 1000
  end

  def start_time
    Time.zone.at(Integer(cookies[processing_time_key]))
  rescue TypeError, ArgumentError
    nil
  end

  def ip
    request.remote_ip
  end

  def user_agent
    request.user_agent
  end

  def payload_data
    {
      v: 1, uip: ip, tid: web_property_id, cid: cookies['_ga'] || SecureRandom.base64,
      ua:  user_agent, t: 'timing', utc: prison.name, utv: visit.processing_state,
      utt: value, utl: user.id, cd1: visit.rejection&.reasons&.sort&.join('-') || ''
    }
  end

  def processing_time_key
    "processing_time-#{visit.id}-#{user.id}"
  end

  def delete_visit_processing_time_cookie
    cookies.delete(processing_time_key)
  end
end
