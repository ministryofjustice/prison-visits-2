Rails.application.config.to_prepare do
  public_service_url = if Rails.env.production?
                         ENV.fetch('PUBLIC_SERVICE_URL')
                       else
                         ENV.fetch(
                           'PUBLIC_SERVICE_URL',
                           'http://localhost:4000'
                         )
                       end

  Rails.configuration.link_directory = LinkDirectory.new(
    prison_finder: 'https://www.gov.uk/guidance/{prison}',
    public_service: public_service_url
  )
end
