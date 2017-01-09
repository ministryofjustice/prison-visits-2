require "rails_helper"

RSpec.describe PVB::Excon::Instrument::Retry do
  include_context 'pvb instrumentation'
  it_behaves_like 'request time logger'

  it 'increments the api_retry_count' do
    expect(Instrumentation).to receive(:incr).with(:api_retry_count)
    subject.process
  end
end
