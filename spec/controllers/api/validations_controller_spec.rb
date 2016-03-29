require 'rails_helper'

RSpec.describe Api::ValidationsController do
  render_views

  let(:parsed_body) {
    JSON.parse(response.body)
  }

  before do
    allow(Nomis::Api).to receive(:enabled?).and_return(true)
    allow(Nomis::Api).to receive(:instance).and_return(instance_double(Nomis::Api))
  end

  describe 'prisoner' do
    let(:params) {
      {
        format: :json,
        first_name: 'Joe',
        last_name: 'Bloggs',
        date_of_birth: '1980-01-01',
        number: 'A1234BC'
      }
    }

    let(:offender) {
      instance_double(Nomis::Offender, id: 123)
    }

    before do
      allow(Nomis::Api.instance).to receive(:lookup_active_offender).
        and_return(offender)
    end

    it 'returns valid if the prisoner exists and can be visisted' do
      expect(Nomis::Api.instance).to receive(:lookup_active_offender).
        and_return(offender)
      post :prisoner, params
      expect(parsed_body['validation']).to eq('valid' => true)
    end

    it 'returns a validation error if the prisoner does not exist' do
      expect(Nomis::Api.instance).to receive(:lookup_active_offender).
        and_return(nil)
      post :prisoner, params
      expect(parsed_body['validation']).to eq(
        'valid' => false,
        'errors' => ['prisoner_does_not_exist']
      )
    end

    it 'returns valid if the NOMIS API is disabled' do
      expect(Nomis::Api).to receive(:enabled?).and_return(false)
      expect(Nomis::Api.instance).not_to receive(:lookup_active_offender)
      post :prisoner, params
      expect(parsed_body['validation']['valid']).to eq(true)
    end
  end
end
