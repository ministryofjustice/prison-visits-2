require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer, '.request_received' do
  let(:visit) {
    create(
      :visit,
      prisoner_first_name: 'Arthur',
      prisoner_last_name: 'Raffles'
    )
  }
  let(:mail) { described_class.request_received(visit) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  around do |example|
    travel_to Date.new(2015, 10, 1) do
      example.call
    end
  end

  include_examples 'template checks'

  it 'reports the request' do
    expect(mail.subject).
      to match(/Visit request for Arthur Raffles on Monday 12 October/)
  end
end
