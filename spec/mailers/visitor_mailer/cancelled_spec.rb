require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.cancelled' do
  let(:visit) { create(:cancelled_visit) }
  let(:mail) { described_class.cancelled(visit) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  around do |example|
    travel_to Date.new(2015, 10, 1) do
      example.call
    end
  end

  include_examples 'template checks'

  it 'sends an email notifying of the visit cancellation' do
    prison_name = visit.prison_name
    expect(mail.subject).
      to match(
        /CANCELLED: Your #{prison_name} prison visit for Monday 12 October/)
  end
end
