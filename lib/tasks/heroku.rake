# frozen_string_literal: true
namespace :heroku do
  desc 'Runs once on the first PR deploy to Heroku, used in app.json'
  task post_deploy: :environment do
    app_name = ENV.fetch('HEROKU_APP_NAME')

    parent_app_id = ENV.fetch('SSO_REVIEW_PARENT_ID')

    service_uri = "https://#{app_name}.herokuapp.com"

    post_data = {
      'parent_app_id' => parent_app_id,
      'new_app_id' => Rails.configuration.sso_app_id,
      'new_app_uri' => service_uri
    }

    connection = Excon.new(
      Rails.configuration.sso_url,
      user: ENV.fetch('SSO_REVIEW_BASIC_USER'),
      password: ENV.fetch('SSO_REVIEW_BASIC_PASSWORD')
    )

    connection.request(
      method: :post,
      path: '/review_apps',
      expects: 200,
      idempotent: true,
      body: post_data.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  desc 'Runs once after the PR is merged or closed, used in app.json'
  task pr_destroy: :environment do
    raise('not a review app') unless ENV['HEROKU_PARENT_APP_NAME']

    delete_data = { 'app_id' => Rails.configuration.sso_app_id }

    connection = Excon.new(
      Rails.configuration.sso_url,
      user: ENV.fetch('SSO_REVIEW_BASIC_USER'),
      password: ENV.fetch('SSO_REVIEW_BASIC_PASSWORD')
    )

    connection.request(
      method: :delete,
      path: '/review_apps',
      expects: 200,
      idempotent: true,
      body: delete_data.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end
