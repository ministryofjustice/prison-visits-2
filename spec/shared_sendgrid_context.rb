RSpec.shared_context 'when sendgrid reports a bounce' do
  before do
    allow_any_instance_of(SendgridApi)
      .to receive(:bounced?).and_return(true)
  end
end

RSpec.shared_context 'when sendgrid reports spam' do
  before do
    allow_any_instance_of(SendgridApi)
      .to receive(:spam_reported?).and_return(true)
  end
end
