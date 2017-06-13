SecureHeaders::Configuration.default do |config|
  config.csp = {
    default_src: ["'self'"],
    font_src: ["'self'", 'data:'],
    img_src: ["'self'", 'data:'],
    style_src: ["'self'", 'www.gstatic.com'],
    connect_src: ["'self'"],
    script_src: [
      "'self'",
      'www.google-analytics.com',
      'www.gstatic.com',
      'https://docs.google.com',
      "'unsafe-eval'",
      "'sha256-+6WnXIl4mbFTCARd8N3COQmT3bJJmo32N8q8ZSQAIcU='",  # govuk
      "'sha256-G29/qSW/JHHANtFhlrZVDZW1HOkCDRc78ggbqwwIJ2g='",  # govuk
      "'sha256-9GTWoKmlaDM3V+GStWlXFaD4tf+wPfBN2ds2eySQ9aE='",  # govuk
      (Rails.env.test? ? "'unsafe-inline'" : '')
    ]
  }

  # So we can send JS errors to Sentry
  sentry_js_dsn = Rails.configuration.sentry_js_dsn

  if sentry_js_dsn.present?
    if sentry_js_dsn.match? URI.regexp(%w[http https])
      config.csp[:connect_src] << URI.parse(sentry_js_dsn).host
    else
      raise '[FATAL] Sentry JS DSN (SENTRY_JS_DSN) is an invalid URI ' \
        '(we were expecting a valid URI with an http or https scheme): ' +
        sentry_js_dsn
    end
  else
    STDOUT.puts '[WARN] Sentry JS DSN is not set (SENTRY_JS_DSN)'
  end
end
