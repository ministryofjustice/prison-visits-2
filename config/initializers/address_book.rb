Rails.application.config.to_prepare do
  Rails.configuration.address_book = AddressBook.new(
    Rails.configuration.action_mailer.smtp_settings.fetch(:domain)
  )
end
