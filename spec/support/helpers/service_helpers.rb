module ServiceHelpers
  def switch_off_api
    allow(Nomis::Api).to receive(:enabled?).and_return(false)
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
end
