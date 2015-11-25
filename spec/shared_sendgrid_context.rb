RSpec.shared_context 'disable resolv for domain' do |domain|
  let(:resolv_response) { double('Resolv::DNS') }

  before do
    allow(resolv_response).to receive(:getresource).with(domain, anything).and_return(true)
    allow(Resolv::DNS).to receive(:new).and_return(resolv_response)
  end
end

RSpec.shared_context 'disable resolv' do
  before do
    allow_any_instance_of(Resolv::DNS).to receive(:getresource).and_return(true)
  end
end

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

RSpec.shared_context 'resolv times out' do
  before do
    allow_any_instance_of(Resolv::DNS).
      to receive(:getresource).and_raise(Resolv::ResolvTimeout)
  end
end

RSpec.shared_context 'resolv raises an error' do
  before do
    allow_any_instance_of(Resolv::DNS).
      to receive(:getresource).and_raise(Resolv::ResolvError)
  end
end
