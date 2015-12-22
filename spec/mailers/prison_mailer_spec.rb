require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer do
  context 'smoke test' do
    let(:visit) {
      create(
        :booked_visit,
        prisoner: create(
          :prisoner,
          first_name: 'Arthur',
          last_name: 'Raffles'
        )
      )
    }

    let(:mail) { described_class.booked(visit) }
    let(:smoke_test_email) {
      "prison-visits-smoke-test+#{'a' * 36}@digital.justice.gov.uk"
    }

    before do
      ActionMailer::Base.deliveries.clear
      allow(visit).to receive(:contact_email_address).
        and_return(smoke_test_email)
    end

    let(:smoke_test) { double('smoke_test_check', matches?: true) }

    it 'changes the to address from the prison email to the smoke test email' do
      mail.deliver_now
      expect(mail.to).to eq([smoke_test_email])
    end
  end
end
