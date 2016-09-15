require 'rails_helper'

RSpec.describe Nomis::Api do
  subject { described_class.instance }

  it 'is implicitly enabled if the api host is configured' do
    expect(Rails.configuration).to receive(:nomis_api_host).and_return(nil)
    expect(described_class.enabled?).to be false

    expect(Rails.configuration).to receive(:nomis_api_host).and_return('http://example.com/')
    expect(described_class.enabled?).to be true
  end

  it 'fails if code attempts to use the client when disabled' do
    expect(described_class).to receive(:enabled?).and_return(false)
    expect {
      described_class.instance
    }.to raise_error(Nomis::DisabledError, 'Nomis API is disabled')
  end

  # Really these tests should be written against the client directly
  describe 'API client' do
    let(:params) {
      {
        noms_id: 'A1459AE',
        date_of_birth: Date.parse('1976-06-12')
      }
    }

    subject { super().lookup_active_offender(params) }

    # Reset the client instance to allow testing configuration
    around do |example|
      Nomis::Api.instance_variable_set(:@instance, nil)
      example.run
      Nomis::Api.instance_variable_set(:@instance, nil)
    end

    it 'sets the X-Request-Id header if a request_id is present', vcr: { cassette_name: 'lookup_active_offender' } do
      RequestStore.store[:request_id] = 'uuid'
      subject
      expect(WebMock).to have_requested(:get, /\w/).
        with(headers: { 'X-Request-Id' => 'uuid' })
    end

    it 'sends an Authorization header containing a JWT token if auth configured', vcr: { cassette_name: 'lookup_active_offender-auth' } do
      expect(Rails.configuration).to receive(:nomis_api_token).and_return('fake')

      # A random private key
      key = OpenSSL::PKey::RSA.new('-----BEGIN RSA PRIVATE KEY-----
MIIBOwIBAAJBAKgRAIAYi4/HbzLcrXf3H3zomuhuimXLWnhqEkCdZ5DBq7ofJpsr
qYv1lPpQUqKhFkAORoj9+w/xM+xIcvFu8t8CAwEAAQJARnKyAf/H6GHRo8FK2WF2
Cna6EDndu2OtLZJQylLwiYVnHs8xLZXdqcAGAv0ZMWEEt2qOBQPxbPQpEWJ6ZhB0
cQIhANE61o8r4DgP15XNI3AYYCbjrgYgxgbKmXJtlK9Vl+f3AiEAzaKXDDGMEVOV
MoFEqkSaIoIiOum28GBj4Soz1gSTolkCIEgDpWff5SvGoCBKXCEv8qBQC0zGqQIb
Z5dQCjYTEtbfAiEAs/pqWbHD9iZBn0Kk5qHEhg+ABjAofZrf0GMvm1HGJYECIQDC
QteHGErMYVksaiuQxrk8I8nbe2JP6UsCd2gyWYazkg==
-----END RSA PRIVATE KEY-----')
      expect(Rails.configuration).to receive(:nomis_api_key).and_return(key)

      subject
      expect(WebMock).to have_requested(:get, /\w/).
        with { |req|
          auth_type, token = req.headers["Authorization"].split(' ')
          next unless auth_type == 'Bearer'
          JWT.decode(token, nil, false) # raises error if not a JWT token
          true
        }
    end
  end

  describe 'lookup_active_offender', vcr: { cassette_name: 'lookup_active_offender' } do
    let(:params) {
      {
        noms_id: 'A1459AE',
        date_of_birth: Date.parse('1976-06-12')
      }
    }

    subject { super().lookup_active_offender(params) }

    it 'returns and offender if the data matches' do
      expect(subject).to be_kind_of(Nomis::Offender)
      expect(subject.id).to eq(1_055_827)
    end

    it 'returns nil if the data does not match', vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
      params[:noms_id] = 'Z9999ZZ'
      expect(subject).to be_nil
    end
  end

  describe 'offender_visiting_availability', vcr: { cassette_name: 'offender_visiting_availability' } do
    let(:params) {
      {
        offender_id: 1_055_827,
        start_date: Date.parse('2016-05-01'),
        end_date: Date.parse('2016-05-21')
      }
    }

    subject { super().offender_visiting_availability(params) }

    it 'returns availability info containing a list of available dates' do
      expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
      expect(subject.dates.first).to eq(Date.parse('2016-05-01'))
    end

    it 'returns empty list of available dates if there is no availability', vcr: { cassette_name: 'offender_visiting_availability-noavailability' } do
      params[:offender_id] = 1_055_847
      expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
      expect(subject.dates).to be_empty
    end

    it 'is an error if the offender does not exist', vcr: { cassette_name: 'offender_visiting_availability-invalid_offender' } do
      params[:offender_id] = 999_999
      expect { subject }.to raise_error(Nomis::NotFound, 'Unknown offender')
    end
  end

  describe 'fetch_bookable_slots', vcr: { cassette_name: 'fetch_bookable_slots' } do
    let(:params) {
      {
        prison: instance_double(Prison, nomis_id: 'LEI'),
        start_date: Date.parse('2016-05-08'),
        end_date: Date.parse('2016-06-01')
      }
    }

    subject { super().fetch_bookable_slots(params) }

    it 'returns an array of slots' do
      expect(subject.first.iso8601).to eq('2016-05-09T10:30/11:30')
    end
  end
end
