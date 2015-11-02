class SendgridApi
  extend SingleForwardable

  def_single_delegators :new, :spam_reported?, :bounced?,
    :remove_from_bounce_list, :remove_from_spam_list

  RETRIEVAL_ERRORS = [JSON::ParserError, SendgridToolkit::APIError]

  def spam_reported?(email)
    api(RETRIEVAL_ERRORS) { spam_reports.retrieve(email: email).any? }
  end

  def bounced?(email)
    api(RETRIEVAL_ERRORS) { bounces.retrieve(email: email).any? }
  end

  REMOVAL_ERRORS = [SendgridToolkit::EmailDoesNotExist]

  def remove_from_bounce_list(email)
    api(REMOVAL_ERRORS) { bounces.delete(email: email) }
  end

  def remove_from_spam_list(email)
    api(REMOVAL_ERRORS) { spam_reports.delete(email: email) }
  end

private

  def api(rescue_from_errors, &_action)
    yield if can_access_sendgrid?
  rescue *rescue_from_errors
    false
  end

  def spam_reports
    SendgridToolkit::SpamReports.new(user_name, password)
  end

  def bounces
    SendgridToolkit::Bounces.new(user_name, password)
  end

  def can_access_sendgrid?
    user_name && password
  end

  def user_name
    smtp_settings[:user_name]
  end

  def password
    smtp_settings[:password]
  end

  def smtp_settings
    Rails.configuration.action_mailer.smtp_settings
  end
end
