require "rails_helper"

RSpec.describe GoogleApiClient do

  let(:user_agent_string) { Faker::Internet.user_agent }

  it 'is able to authenticate', vcr: { cassette_name: 'google_analytics', record: :all } do
    subject.ga_event user_agent
  end
end
