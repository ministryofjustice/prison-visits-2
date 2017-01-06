require "rails_helper"
require 'pvb/excon/instrument'

RSpec.describe PVB::Excon::Instrument::Request do
  let(:nowish)           { Time.zone.now }
  let(:start)            { nowish }
  let(:finish)           { nowish + 0.5 }
  let(:payload)          { { method: :get, path: '/some/path' } }

  subject { described_class.new(start, finish, payload) }

  describe '#process' do
    it 'increments the api_request_count' do
      expect(Instrumentation).to receive(:incr).with(:api_request_count)
      subject.process
    end

    it 'appends request time to the total request time' do
      expect(Instrumentation).to receive(:append_to_log).with(api: 500)
      subject.process
    end

    it 'logs the current request time' do
      expect(Rails.logger).to receive(:info).with("Calling NOMIS API: GET /some/path - 500.00ms")
      subject.process
    end
  end
end
