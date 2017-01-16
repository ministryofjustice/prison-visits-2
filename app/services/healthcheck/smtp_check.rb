# frozen_string_literal: true
require 'net/smtp'

class Healthcheck
  class SmtpCheck
    include CheckComponent

    def initialize(description, smtp_settings:)
      host = smtp_settings.fetch(:address)
      port = smtp_settings.fetch(:port)

      build_report description do
        { ok: alive?(host, port) }
      end
    end

    def alive?(host, port)
      Net::SMTP.start(host, port) do |smtp|
        smtp.enable_starttls_auto
        smtp.ehlo(Socket.gethostname)
        smtp.finish
      end
      true
    end
  end
end
