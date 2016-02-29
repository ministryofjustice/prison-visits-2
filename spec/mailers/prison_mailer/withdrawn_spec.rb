require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer, '.withdrawn' do
  let(:prisoner) {
    create(:prisoner, first_name: 'Arthur', last_name: 'Raffles')
  }

  let(:mail) { described_class.withdrawn(visit) }

  around do |example|
    ActionMailer::Base.deliveries.clear
    travel_to(Date.new(2015, 6, 1)) do
      example.run
    end
  end

  context 'withdrawn visit' do
    let(:visit) { create(:withdrawn_visit, prisoner: prisoner) }
    include_examples 'template checks'

    it 'sends an email notifyting the prison of the withdrawal' do
      expect(mail.subject).to eq('WITHDRAWN: Visit request for Arthur Raffles')
    end
  end
end
