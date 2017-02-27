require "rails_helper"

RSpec.describe PVB::Instrumentations::Excon::Error do
  let(:nowish)           { Time.zone.now }
  let(:start)            { nowish }
  let(:finish)           { nowish + 0.5 }
  let(:payload)          { { method: :get, path: '/some/path' } }

  subject { described_class.new(start, finish, payload) }

  describe '#process' do
    it 'increments the api_error_count' do
      expect(Instrumentation).to receive(:incr).with(:api_error_count)
      subject.process
    end
  end
end
