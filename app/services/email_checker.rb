class EmailChecker
  def initialize(original_address, override_sendgrid = false)
    @original_address = original_address
    @parsed = parse_address(original_address)
    @override_sendgrid = override_sendgrid
  end

  def error
    @error ||= compute_error.to_s.inquiry
  end

  def message
    I18n.t(error, scope: 'email_checker.errors')
  end

  def valid?
    error.valid?
  end

  def delivery_error_occurred?
    error.spam_reported? || error.bounced?
  end

  def reset_bounce?
    return false unless parsed
    override_sendgrid? && sendgrid_api.bounced?(parsed.address)
  end

  def reset_spam_report?
    return false unless parsed
    override_sendgrid? && sendgrid_api.spam_reported?(parsed.address)
  end

private

  attr_reader :original_address, :parsed

  def compute_error
    format_error || mx_records_error || sendgrid_error || :valid
  end

  def format_error
    return :unparseable unless parsed
    return :domain_dot if domain_dot_error?
    return :malformed unless well_formed_address?
  end

  def mx_records_error
    return :no_mx_record unless mx_records?
  end

  def sendgrid_error
    unless override_sendgrid?
      Metrics.log('Validating email address via Sendgrid API') do
        return :spam_reported if sendgrid_api.spam_reported?(parsed.address)
        return :bounced if sendgrid_api.bounced?(parsed.address)
      end
    end
  end

  def override_sendgrid?
    @override_sendgrid || !Rails.configuration.enable_sendgrid_validations
  end

  def domain
    parsed.domain
  end

  def parse_address(addr)
    Mail::Address.new(addr)
  rescue Mail::Field::ParseError
    nil
  end

  def domain_dot_error?
    domain && domain.start_with?('.')
  end

  def well_formed_address?
    parsed.local && parsed.domain &&
      parsed.address == original_address && parsed.local != original_address
  end

  def mx_records?
    Metrics.log('Validating email address MX record') do
      Rails.configuration.mx_checker.records?(domain)
    end
  end

  def sendgrid_api
    Rails.configuration.sendgrid_api
  end
end
