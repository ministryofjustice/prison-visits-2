RSpec.shared_context 'pvb instrumentation' do
  let(:nowish)           { Time.zone.now }
  let(:start)            { nowish }
  let(:finish)           { nowish + 0.5 }
  let(:payload)          { { method: :get, path: '/some/path' } }

  subject { described_class.new(start, finish, payload) }
end
RSpec.shared_examples_for 'request time logger' do
  it 'logs the current request time' do
    expect(Rails.logger).to receive(:info).with("Calling NOMIS API: GET /some/path - 500.00ms")
    subject.process
  end
end
