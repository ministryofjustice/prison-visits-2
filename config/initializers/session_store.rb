# Be sure to restart your server when you modify this file.

unless Rails.env.test?
  Rails.application.config.session_store :active_record_store,
                                         key: '_pvb2_session',
                                         expire_after: 1.hour
end
