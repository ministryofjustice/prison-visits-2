require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.request_acknowledged' do
  let(:visit) { create(:visit) }
  subject { described_class.request_acknowledged(visit) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  include_examples 'template checks'

  it 'sends an email acknowleging the request' do
    expect(subject.subject).
      to match(/received your visit request for \w+ \d+ \w+\z/)
  end

  context 'spam and bounce handling' do
    before do
      visit.save
    end

    let(:reset_call) { double(SpamAndBounceResets, perform_resets: true) }

    it 'resets sendgrid spam and bounce settings before sending' do
      expect(SpamAndBounceResets).to receive(:new).and_return(reset_call)
      subject.deliver_now
    end
  end
end
