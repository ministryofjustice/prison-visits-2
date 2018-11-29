require 'rails_helper'

RSpec.describe Api::ValidationsController do
  render_views

  let(:parsed_body) {
    JSON.parse(response.body)
  }

  before do
    allow(Nomis::Api).to receive(:enabled?).and_return(true)
  end

  describe 'visitors' do
    let!(:prison)   { FactoryBot.create(:prison) }
    let(:prison_id) { prison.id }
    let(:lead_dob)  { '1990-01-01' }
    let(:dobs)      { [lead_dob] }

    let(:params) do
      {
        lead_date_of_birth: lead_dob,
        dates_of_birth: dobs,
        prison_id: prison_id
      }
    end

    subject { post :visitors, params: params.merge(format: :json) }

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

      it { is_expected.not_to be_successful }

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

    context 'when the prisoner exists' do
      let(:prisoner_validation) do
        ApiPrisonerChecker
      end

      it 'returns valid' do
        expect(ApiPrisonerChecker).
          to receive(:new).with(
            noms_id: params[:number],
            date_of_birth: Date.parse(params[:date_of_birth])
             ).and_return(double(ApiPrisonerChecker, 'valid?' => true))

        post :prisoner, params: params
        expect(parsed_body['validation']).to eq('valid' => true)
      end
    end

    context 'when the prisoner does not exist' do
      let(:prisoner) { Nomis::NullPrisoner.new(api_call_successful: true) }

      it 'returns a validation error' do
        expect(Nomis::Api.instance).to receive(:lookup_active_prisoner).
          and_return(prisoner)

        post :prisoner, params: params
        expect(parsed_body['validation']).to eq(
          'valid' => false,
          'errors' => ['prisoner_does_not_exist']
        )
      end
    end

    it 'returns an error if the date of birth is invalid' do
      params[:date_of_birth] = '1980-50-01'
      expect(Nomis::Api.instance).not_to receive(:lookup_active_prisoner)

      post :prisoner, params: params
      expect(response.status).to eq(422)
      expect(parsed_body['message']).to eq('Invalid parameter: date_of_birth')
    end

    it 'returns valid if the NOMIS API cannot be contacted', :expect_exception do
      allow_any_instance_of(Nomis::Client).to receive(:get).
        and_raise(Nomis::APIError, 'Something broke')

      post :prisoner, params: params
      expect(parsed_body['validation']['valid']).to eq(true)
    end
  end
end
