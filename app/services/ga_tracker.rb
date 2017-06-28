class GATracker

  ENDPOINT = URI.parse('https://www.google-analytics.com/collect').freeze

  def initialize(user, prison)
    self.user_agent      = request.user_agent
    self.ip              = request.ip
    self.web_property_id = Rails.application.config.ga_id
  end

  def send_event(request)
    data = payload_data(user, prison, value)
    client.post(
      path: ENDPOINT.path,
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',

      },
      body: URI.encode_www_form(data)
    )
  end

  private
  attr_accessor :web_property_id, :user_agent, :ip

  def client
    @client ||= Excon.new(ENDPOINT.to_s, persistent: true)
  end

  def value
    (Time.zone.now - start_time).to_i
  end
  def start_time
    request.cookies
  end

  def payload_data(user_agent, ip, user, prison, value)
    {
      v:   1,
      uip: ip,
      tid: web_property_id,
      cid: SecureRandom.base64,
      ua:  user_agent,
      t:   'timing',
      utc: prison.name,
      utv: 'Process',
      utt: value,
      utl: user.id
    }
  end

end
