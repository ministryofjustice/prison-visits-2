require 'rails_helper'

RSpec.describe VisitorMailer do
  subject! { described_class }

  before do
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(VisitorMailer).to receive(:smtp_domain).and_return('example.com')
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2013, 7, 4)) do
      example.run
    end
  end
end
