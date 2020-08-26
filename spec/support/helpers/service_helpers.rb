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

  # allow feature tests to login for specific prisons
  def prison_login(estates, email_address = 'joe@example.com', roles = [])
    sso_response =
      {
        'uid' => '1234-1234-1234-1234',
        'provider' => 'hmpps_sso',
        'info' => {
          'first_name' => 'Joe',
          'last_name' => 'Goldman',
          'user_id' => 485_926,
          'email' => email_address,
          'organisations' => estates.map(&:nomis_id),
          'roles' => roles,
        }
      }

    OmniAuth.config.add_mock(:hmpps_sso, sso_response)
  end
end
