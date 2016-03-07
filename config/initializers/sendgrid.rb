SendgridClient.instance.configure(
  api_key: Rails.configuration.sendgrid_api_key,
  api_user: Rails.configuration.sendgrid_api_user)
