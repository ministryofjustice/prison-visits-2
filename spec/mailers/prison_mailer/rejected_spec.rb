require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer, '.rejected' do
  let(:rejection) {
    create(
      :rejection,
      visit: create(
        :rejected_visit,
        prisoner: create(
          :prisoner,
          first_name: 'Arthur',
          last_name: 'Raffles'
        )
      )
    )
  }
  let(:mail) { described_class.rejected(rejection.visit) }
  let(:body) { mail.html_part.body }

  before do
    ActionMailer::Base.deliveries.clear
  end

  include_examples 'template checks'
  include_examples 'noreply checks'

  it 'sends an email reporting the rejection' do
    expect(mail.subject).
      to match(/COPY of booking rejection for Arthur Raffles/)
  end
end
