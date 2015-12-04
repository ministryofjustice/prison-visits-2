require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.request_acknowledged' do
  let(:visit) { create(:visit) }
  let(:mail) { described_class.request_acknowledged(visit) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  around do |example|
    travel_to Date.new(2015, 10, 1) do
      example.call
    end
  end

  include_examples 'template checks'

  it 'acknowledges the request' do
    expect(mail.subject).
      to match(/received your visit request for Monday 12 October/)
  end

  context 'spam and bounce handling' do
    before do
      visit.save
    end

    let(:reset_call) { double(SpamAndBounceResets, perform_resets: true) }

    it 'resets sendgrid spam and bounce settings before sending' do
      expect(SpamAndBounceResets).to receive(:new).and_return(reset_call)
      mail.deliver_now
    end
  end
end
