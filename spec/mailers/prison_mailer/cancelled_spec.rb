require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer, '.cancelled' do
  let(:prisoner) {
    create(:prisoner, first_name: 'Arthur', last_name: 'Raffles')
  }
  let(:visit) { create(:cancelled_visit, prisoner: prisoner, slot_granted: '2015-11-06T16:00/17:00') }

  let(:mail) { described_class.cancelled(visit) }

  around do |example|
    ActionMailer::Base.deliveries.clear
    travel_to(Date.new(2015, 6, 1)) do
      example.run
    end
  end

  include_examples 'template checks'
  include_examples 'noreply checks'
  include_examples 'skipping email for the trial'

  context 'cancelled visit' do
    include_examples 'template checks'

    it 'sends an email notifyting the prison of the cancellation' do
      expect(mail.subject).to eq('CANCELLED: Visit for Arthur Raffles on Friday 6 November')
      expect(mail['X-Priority'].value).to eq('1 (Highest)')
      expect(mail['X-MSMail-Priority'].value).to eq('High')
    end

    it 'sends an email containing the visit id and reference number' do
      expect(mail.body.encoded).to match(prisoner.number)
      expect(mail.body.encoded).to match(visit.id)
    end
  end
end
