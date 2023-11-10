require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.one_off_message' do
  before do
    ActionMailer::Base.deliveries.clear
  end

  let(:visit) { FactoryBot.create(:booked_visit) }
  let(:message) { FactoryBot.create(:message, visit:) }
  let(:mail) { described_class.one_off_message(message) }

  include_examples 'template checks'

  it { expect(mail.html_part.body).to match(message.body) }
end
