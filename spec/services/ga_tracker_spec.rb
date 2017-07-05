require "rails_helper"

RSpec.describe GATracker do
  let(:user_agent)          { 'some user agent string' }
  let(:ip)                  { FFaker::InternetSE.ip_v4_address  }
  let(:user)                { create :user }
  let(:visit)               { create(:visit) }
  let(:processing_time_key) { "processing_time-#{visit.id}-#{user.id}"  }
  let(:request)             { ActionDispatch::TestRequest.new('REMOTE_ADDR' => ip, 'HTTP_USER_AGENT' => user_agent) }
  let(:cookies)             { ActionDispatch::Cookies::CookieJar.build(request) }
  let(:nowish)              { Time.zone.now }
  let(:web_property_id)     { "UA-96772907-2" }

  subject { described_class.new(user, visit.reload, cookies, request)  }

  describe '#send_event' do
    before do
      switch_feature_flag_with :ga_id, web_property_id
      cookies['_ga'] = 'some_client_id'
      travel_to nowish - 2.minutes do
        subject.set_visit_processing_time_cookie
      end
      reject_visit visit
    end

    it 'sends an event', vcr: { cassette_name: 'google_analytics' } do
      travel_to nowish do
        subject.send_event
      end
      expect(WebMock).
        to have_requested(:post, GATracker::ENDPOINT).with(
          body: URI.encode_www_form(
            v: 1,
            uip: ip,
            tid: web_property_id,
            cid: "some_client_id",
            ua: user_agent,
            t: "timing",
            utc: visit.prison.name,
            utv: visit.processing_state,
            utt: 120_000,
            utl: user.id,
            cd1: "slot_unavailable"
          ),
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Host' => 'www.google-analytics.com:443', 'User-Agent' => Excon::USER_AGENT }
           )
      expect(cookies[processing_time_key]).to be_nil
    end
  end

  describe '#set_visit_processing_time_cookie' do
    context 'when the cookie has not been yet set' do
      it 'sets the processing time' do
        travel_to nowish do
          expect {
            subject.set_visit_processing_time_cookie
          }.to change { cookies[processing_time_key]  }.from(nil).to(nowish.to_i)
        end
      end
    end

    describe 'when the cookies has already been set' do
      before do
        travel_to 2.minutes.ago do
          subject.set_visit_processing_time_cookie
        end
      end

      it 'does not change its value' do
        expect {
          subject.set_visit_processing_time_cookie
        }.not_to change { cookies[processing_time_key] }
      end
    end
  end
end
