require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.one_off_message' do
  before do
    ActionMailer::Base.deliveries.clear
  end
  let(:message) { FactoryGirl.create(:message) }
  let(:mail) { described_class.one_off_message(message) }

  include_examples 'template checks'

  it { expect(mail.html_part.body).to match(message.body) }
end
