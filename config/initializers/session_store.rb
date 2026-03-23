# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :active_record_store,
                                       key: '_pvb_staff_session',
                                       expire_after: 1.hour unless Rails.env.test?
