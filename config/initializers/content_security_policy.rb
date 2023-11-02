Rails.application.config.content_security_policy do |config|
  config.default_src :self
  config.font_src :self, :data
  config.img_src :self, :data, 'www.google-analytics.com'

  config.style_src :self, 'www.gstatic.com'

  config.connect_src :self
  config.script_src :self,
                    'www.google-analytics.com',
                    'www.gstatic.com',
                    'https://docs.google.com',
                    "'unsafe-eval'",
                    "'sha256-+6WnXIl4mbFTCARd8N3COQmT3bJJmo32N8q8ZSQAIcU='",  # govuk
                    "'sha256-G29/qSW/JHHANtFhlrZVDZW1HOkCDRc78ggbqwwIJ2g='",  # govuk
                    "'sha256-9GTWoKmlaDM3V+GStWlXFaD4tf+wPfBN2ds2eySQ9aE='",  # govuk
                    (Rails.env.test? ? "'unsafe-inline'" : '')

  # So we can send JS errors to Sentry
  sentry_js_dsn = Rails.configuration.sentry_js_dsn

  if sentry_js_dsn.present?
    if sentry_js_dsn.match? URI::DEFAULT_PARSER.make_regexp(%w[http https])
      host = URI.parse(sentry_js_dsn).host
      config.connect_src :self, host
    else
      raise '[FATAL] Sentry JS DSN (SENTRY_JS_DSN) is an invalid URI ' \
        '(we were expecting a valid URI with an http or https scheme): ' +
        sentry_js_dsn
    end
  else
    $stdout.puts '[WARN] Sentry JS DSN is not set (SENTRY_JS_DSN)'
  end
end
