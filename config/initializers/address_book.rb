Rails.application.config.to_prepare do
  Rails.configuration.address_book = AddressBook.new(
    Rails.configuration.email_setttings.fetch(:domain)
  )
end
