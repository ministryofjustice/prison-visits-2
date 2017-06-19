require 'googleauth'
require 'google/apis/analytics_v3'

class GoogleApiClient

  ENDPOINT = URI.parse('https://www.google-analytics.com/collect').freeze

  def initialize
    self.web_property_id = Rails.application.config.ga_id
  end

  def ga_event(user_agent, ip, cid)
    client.post(
      path: ENDPOINT.path,
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded',

      },
      body: URI.encode_www_form(payload_data(cid))
    )
  end

  private
  attr_accessor :client, :web_property_id

  def client
    @client ||= Excon.new(ENDPOINT.host, persistent: true)
  end

  def payload_data(cid, user_agent, ip)
    {
      v: 1,
      tid: web_property_id,
      cid: cid,
      t:   'visit_processed',
      ua:  user_agent,
      uip: ip
    }
  end

end
