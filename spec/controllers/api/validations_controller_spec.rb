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

  describe 'visitors' do
    let!(:prison) { FactoryGirl.create(:prison) }
    let(:prison_id) { prison.id }
    let(:lead_dob) { '1990-01-01' }
    let(:dobs) { [lead_dob] }

    let(:params) do
      {
        lead_date_of_birth: lead_dob,
        dates_of_birth: dobs,
        prison_id: prison_id
      }
    end

    subject { post :visitors, params.merge(format: :json) }

    context 'when the group of visitors conform to the prison rules' do
      it { is_expected.to be_successful }

      it 'returns a body' do
        subject
        expect(parsed_body).to eq('validation' => { 'valid' => true })
      end
    end

    context 'when there are too many adults' do
      let(:dobs) { [lead_dob, lead_dob, lead_dob, lead_dob] }

      it { is_expected.to be_successful }

      it 'returns a body' do
        subject
        expect(parsed_body).
          to eq('validation' => { 'valid' => false,
                                  'errors' => ['too_many_adults'] })
      end
    end

    context 'when the prison_id is missing' do
      let(:prison_id) { nil }

      it { is_expected.to_not be_successful }

      it 'returns a body' do
        subject
        expect(parsed_body).to eq(
          'message' => 'Invalid parameter: prison_id')
      end
    end

    context 'when the prison_id is not found' do
      let(:prison_id) { 'foo' }

      it 'returns a body' do
        subject
        expect(parsed_body).to eq(
          'message' => 'Invalid parameter: prison_id')
      end
    end

    context 'when the data is invalid' do
      let(:lead_dob) { '2015-01-01' }

      it { is_expected.to be_successful }

      it 'returns a body' do
        subject
        expect(parsed_body).to eq(
          'validation' => {
            'valid' => false,
            'errors' => ['lead_visitor_age']
          })
      end
    end
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

    it 'returns an error if the date of birth is invalid' do
      params[:date_of_birth] = '1980-50-01'
      expect(Nomis::Api.instance).not_to receive(:lookup_active_offender)
      post :prisoner, params
      expect(response.status).to eq(422)
      expect(parsed_body['message']).to eq('Invalid parameter: date_of_birth')
    end

    it 'returns valid if the NOMIS API is disabled' do
      expect(Nomis::Api).to receive(:enabled?).and_return(false)
      expect(Nomis::Api.instance).not_to receive(:lookup_active_offender)
      post :prisoner, params
      expect(parsed_body['validation']['valid']).to eq(true)
    end

    it 'returns valid if the NOMIS API cannot be contacted' do
      allow(Nomis::Api.instance).to receive(:lookup_active_offender).
        and_raise(Excon::Errors::Error, 'Something broke')
      expect(Rails.logger).to receive(:warn).with(
        'Error calling the NOMIS API: #<Excon::Errors::Error: Something broke>'
      )
      post :prisoner, params
      expect(parsed_body['validation']['valid']).to eq(true)
    end
  end
end
