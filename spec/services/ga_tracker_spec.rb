require "rails_helper"

RSpec.describe GATracker do

  let(:user_agent) { 'some user agent string' }
  let(:ip)         { FFaker::InternetSE.ip_v4_address  }
  let(:user)       { create :user }
  let(:prison)     { create :prison }

  it 'is able to authenticate', vcr: { cassette_name: 'google_analytics', record: :all } do
    subject.ga_event user_agent, ip, user, prison, 3600
  end

end
