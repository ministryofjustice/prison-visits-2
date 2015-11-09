require 'rails_helper'

RSpec.describe VisitorMailer, '.request_acknowledged' do
  let(:visit) { build(:visit) }
  subject { described_class.request_acknowledged(visit) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  it 'sends an email acknowleging the request' do
    expect(subject.subject).to match(/Not booked yet/)
  end

end
