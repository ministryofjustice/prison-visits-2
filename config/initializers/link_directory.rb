public_service_url = Rails.env.production? ? ENV.fetch('PUBLIC_SERVICE_URL') : 'http://localhost:4000'

Rails.configuration.link_directory = LinkDirectory.new(
  prison_finder: 'http://www.justice.gov.uk/contacts/prison-finder{/prison}',
  public_service: "#{public_service_url}/{path}"
)
