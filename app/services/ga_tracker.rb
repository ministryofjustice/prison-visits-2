class GATracker
  ENDPOINT = URI.parse('https://www.google-analytics.com/collect').freeze

  def initialize(user, visit, cookies, request)
    self.user            = user
    self.visit           = visit
    self.prison          = visit.prison
    self.cookies         = cookies
    self.request         = request
    self.web_property_id = Rails.application.config.ga_id
    self.client          = Excon.new(ENDPOINT.to_s, persistent: true)
    self.ip              = request.ip
    self.user_agent      = request.user_agent
  end

  def set_visit_processing_time_cookie
    cookies[processing_time_key] ||= {
      value: Time.zone.now.to_i, expires: 1.week.from_now
    }
  end

  def send_unexpected_rejection_event
    if visit_rejected_unexpectedly?
      send_data(build_event_payload(ga_cookie, 'Manual rejection',
                                    visit.rejection.reasons.sort.join('-')))
    end
  end

  def send_rejection_event
    if visit.rejected?
      send_data(build_event_payload(ga_cookie, 'Rejection',
                                    visit.rejection.reasons.sort.join('-')))
    end
  end

  def send_booked_visit_event
    send_data(build_event_payload(ga_cookie, 'Booked', booked_method)) if visit.booked?
  end

  def send_cancelled_visit_event
    if visit.cancelled?
      send_data(build_event_payload(ga_cookie, 'Cancelled',
                                    visit.cancellation.reasons.sort.join('-')))
    end
  end

  def send_withdrawn_visit_event
    send_data(build_event_payload(ga_cookie, 'Withdrawn', nil)) if visit.withdrawn?
  end

  def send_processing_timing
    return unless timing_value

    send_data(timing_payload_data)
    delete_visit_processing_time_cookie
  end

private

  attr_accessor :web_property_id, :user, :prison, :visit, :cookies, :request, :client,
                :ip, :user_agent

  def send_data(payload)
    client.post(
      path: ENDPOINT.path,
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
      body: URI.encode_www_form(payload)
    )
  end

  def booked_method
    visit.nomis_id.nil? ? 'Manual' : 'NOMIS'
  end

  def visit_rejected_unexpectedly?
    visit.rejected? &&
      ActiveRecord::Type::Boolean.new.cast(request.params[:was_bookable])
  end

  def timing_value
    return unless start_time

    (Time.zone.now - start_time).to_i * 1000
  end

  def start_time
    Time.zone.at(cast_processing_time_key) if cast_processing_time_key
  end

  def cast_processing_time_key
    Integer(cookies[processing_time_key])
  rescue TypeError => e
    PVB::ExceptionHandler.capture_exception(e)
  end

  def timing_payload_data
    {
      v: 1, uip: ip, tid: web_property_id, cid: cookies['_ga'] || SecureRandom.base64,
      ua: user_agent, t: 'timing', utc: prison.name, utv: visit.processing_state,
      utt: timing_value, utl: user.id,
      cd1: visit.rejection&.reasons&.sort&.join('-') || ''
    }
  end

  def build_event_payload(cookie, action, label)
    {
      v: 1, uip: ip, tid: web_property_id, cid: cookie,
      ua: user_agent, t: 'event', ec: prison.name, ea: action,
      el: label
    }
  end

  def processing_time_key
    "processing_time-#{visit.id}-#{user.id}"
  end

  def delete_visit_processing_time_cookie
    cookies.delete(processing_time_key)
  end

  def ga_cookie
    cookies['_ga'] || SecureRandom.base64
  end
end
