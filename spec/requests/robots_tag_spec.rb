require 'rails_helper'

RSpec.describe RobotsTag do
  it "blocks all crawlers" do
    get '/'
    expect(response.headers["X-Robots-Tag"]).to eq "noindex, nofollow"
  end
end
