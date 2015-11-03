class SendgridApi
  extend SingleForwardable

  def_single_delegators :new, :spam_reported?, :bounced?,
    :remove_from_bounce_list, :remove_from_spam_list

  def spam_reported?(email)
    api { spam_reports.retrieve(email: email).any? }
  end

  def bounced?(email)
    api { bounces.retrieve(email: email).any? }
  end

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
end
