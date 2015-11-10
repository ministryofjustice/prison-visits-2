module NoReply
  extend ActiveSupport::Concern

  included do
    default from: I18n.t('mailer.noreply', domain: smtp_settings[:domain])
  end
end
