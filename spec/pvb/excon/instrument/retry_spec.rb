require "rails_helper"

RSpec.describe PVB::Excon::Instrument::Retry do
  include_context 'pvb instrumentation'
  it_behaves_like 'request time logger'
end
