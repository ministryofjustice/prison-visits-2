require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module PrisonVisits
  class Application < Rails::Application
    # TODO: The template needs these, but they are set before we know which
    # locale to use, so we can't use I18n.t().
    config.app_title = 'Visit someone in prison'
    config.proposition_title = 'Visit someone in prison'
    config.phase = 'live'
    config.product_type = 'service'

    config.autoload_paths += %w[ app/mailers/concerns ]

    config.i18n.load_path +=
      Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    config.time_zone = 'London'

    config.active_record.raise_in_transactional_callbacks = true
  end
end
