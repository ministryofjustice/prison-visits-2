# Be sure to restart your server when you modify this file.

session_store_options = {}
session_store_options[:key] = '_pvb2_session'
session_store_options[:expire_after] = 1.hour unless Rails.env.test?

Rails.application.config.session_store :cookie_store, session_store_options
