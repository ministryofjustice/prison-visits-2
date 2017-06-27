class GoogleApiClient

  ENDPOINT = URI.parse('https://www.google-analytics.com/collect').freeze

  def initialize
    self.web_property_id = Rails.application.config.ga_id
  end

  def ga_event(user_agent, ip, user, prison, value)
    data = payload_data(user_agent, ip, user, prison, value)
    client.post(
      path: ENDPOINT.path,
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',

      },
      body: URI.encode_www_form(data)
    )
  end

  private
  attr_accessor :client, :web_property_id

  def client
    @client ||= Excon.new(ENDPOINT.to_s, persistent: true)
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
