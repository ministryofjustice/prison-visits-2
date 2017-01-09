require "rails_helper"
require 'pvb/excon/instrument'

RSpec.describe PVB::Excon::Instrument::Request do
  include_context 'pvb instrumentation'

  describe '#process' do
    it 'increments the api_request_count' do
      expect(Instrumentation).to receive(:incr).with(:api_request_count)
      subject.process
    end

    it 'appends request time to the total request time' do
      subject.process
      expect(Instrumentation.custom_log_items).to include(api: 500)
    end

    it_behaves_like 'request time logger'
  end
end
