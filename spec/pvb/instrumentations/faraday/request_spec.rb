require "rails_helper"

RSpec.describe PVB::Instrumentations::Faraday::Request do
  include_context 'pvb instrumentation'
  let(:payload) { double(Faraday::Env, status: 200) }

  it 'logs the resquest time and status' do
    subject.process
    expect(Instrumentation.custom_log_items).to include(
      sentry: { status: 200, request_time: 500 }
                                                )
  end
end
