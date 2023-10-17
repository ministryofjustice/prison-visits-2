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
    expect(mail.subject)
      .to match(/received your visit request for Monday 12 October/)
  end

  it 'uses the locale of the visit' do
    visit.update locale: 'cy'
    expect(mail.subject)
      .to match(
        /mae eich cais i ymweld ar Dydd Llun 12 Hydref wedi cyrraedd/)
  end
end
