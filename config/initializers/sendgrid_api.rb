if Rails.configuration.disable_sendgrid_validations
  SendgridApi.instance.disable
end
