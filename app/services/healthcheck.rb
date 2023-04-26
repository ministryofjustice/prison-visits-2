require 'sidekiq/api'

class Healthcheck
  def initialize
    @components = {
      database: DatabaseCheck.new('Postgres database')
      # mailers: QueueCheck.new('Email queue', queue_name: 'mailers'),
      # zendesk: QueueCheck.new('Zendesk queue', queue_name: 'zendesk'),
      # smtp: SmtpCheck.new('SMTP server', smtp_settings: smtp_settings)
    }
  end

  def ok?
    @components.values.all?(&:ok?)
  end

  def checks
    @components.inject(ok: ok?) { |hash, (key, checker)|
      hash.merge(key => checker.report)
    }
  end

  def smtp_settings
    Rails.configuration.action_mailer.smtp_settings
  end
end
