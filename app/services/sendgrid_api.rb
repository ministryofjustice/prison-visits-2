class SendgridApi
  extend SingleForwardable

  def_single_delegators :new, :spam_reported?, :bounced?,
    :remove_from_bounce_list, :remove_from_spam_list

  RETRIEVAL_ERRORS = [JSON::ParserError, SendgridToolkit::APIError]

  def spam_reported?(email)
    api { spam_reports.retrieve(email: email).any? }
  end

  def bounced?(email)
    api { bounces.retrieve(email: email).any? }
  end

  REMOVAL_ERRORS = [SendgridToolkit::EmailDoesNotExist]

  def remove_from_bounce_list(email)
    api { bounces.delete(email: email) }
  end

  def remove_from_spam_list(email)
    api { spam_reports.delete(email: email) }
  end

private

  def api(&_action)
    yield
  rescue => e
    Rails.logger.error("SendgridApi error: #{e.class} #{e}")
    false
  end

  def spam_reports
    SendgridToolkit::SpamReports.new
  end

  def bounces
    SendgridToolkit::Bounces.new
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
    Rails.configuration.action_mailer.smtp_settings || {}
  end
end
