require 'rails_helper'

RSpec.describe PingController do
  it 'returns a JSON structure read from the configuration' do
    allow(Rails.configuration)
      .to receive(:version_info)
      .and_return('foo' => 'bar')
    get :index
    expect(response.body).to eq('{"foo":"bar"}')
  end
end
