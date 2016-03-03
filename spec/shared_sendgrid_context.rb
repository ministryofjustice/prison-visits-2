RSpec.shared_context 'sendgrid reports a bounce' do
  before do
    allow(SendgridApi).to receive(:bounced?).at_least(:once).and_return(true)
  end
end

RSpec.shared_context 'sendgrid reports spam' do
  before do
    allow(SendgridApi).to receive(:spam_reported?).at_least(:once).and_return(true)
  end
end

RSpec.shared_context 'sendgrid timeouts' do
  before do
    allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
  end
end
