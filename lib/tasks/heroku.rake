namespace :heroku do
  desc 'Runs once on the first PR deploy to Heroku, used in app.json'
  task :post_deploy do
    require 'excon'

    sso_url = ENV.fetch('MOJSSO_URL')

    app_name = ENV.fetch('HEROKU_APP_NAME')

    service_uri = "https://#{app_name}.herokuapp.com"

    new_app_name = "Prison Visits Booking (review app: #{app_name})"

    post_data = {
      'app_name' => 'Prison Visits Booking',
      'new_app_name' => new_app_name,
      'new_app_uri' => service_uri
    }

    connection = Excon.new(
      sso_url,
      user: ENV.fetch('SSO_BASIC_USER'),
      password: ENV.fetch('SSO_BASIC_PASSWORD')
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
  task :pr_destroy do
    require 'excon'

    sso_url = ENV.fetch('MOJSSO_URL')

    app_name = ENV.fetch('HEROKU_APP_NAME')
    new_app_name = "Prison Visits Booking (review app: #{app_name})"

    delete_data = { 'new_app_name' => new_app_name }

    connection = Excon.new(
      sso_url,
      user: ENV.fetch('SSO_BASIC_USER'),
      password: ENV.fetch('SSO_BASIC_PASSWORD')
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
