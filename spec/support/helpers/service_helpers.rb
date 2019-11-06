module ServiceHelpers
  def switch_feature_off_for(feature, feature_for)
    expect(Nomis::Feature).to receive(feature).with(feature_for).and_return(false)
  end

  def switch_off_api
    allow(Nomis::Api).to receive(:enabled?).and_return(false)
  end

  def switch_on_api
    allow(Nomis::Api).to receive(:enabled?).and_return(true)
  end

  def mock_service_with(klass, double_or_spy)
    expect(klass).to receive(:new).and_return(double_or_spy)
  end

  def mock_nomis_with(api, double_or_spy)
    expect(Nomis::Api.instance).to receive(api).and_return(double_or_spy)
  end

  def simulate_api_error_for(api, exception_class = Nomis::APIError)
    expect(Nomis::Api.instance).to receive(api).and_raise(exception_class)
  end

  # allow feature tests to login for a specific prison
  def prison_login(prison)
    sso_response =
      {
        'uid' => '1234-1234-1234-1234',
        'provider' => 'mojsso',
        'info' => {
          'first_name' => 'Joe',
          'last_name' => 'Goldman',
          'email' => 'joe@example.com',
          'permissions' => [
            { 'organisation' => prison.estate.sso_organisation_name, roles: [] }
          ],
          'links' => {
            'profile' => 'http://example.com/profile',
            'logout' => 'http://example.com/logout'
          }
        }
      }

    OmniAuth.config.add_mock(:mojsso, sso_response)
  end
end
