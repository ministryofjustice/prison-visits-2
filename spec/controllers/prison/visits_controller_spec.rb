# require 'rails_helper'

# RSpec.describe Prison::VisitsController, type: :controller do
#   let(:visit) { FactoryBot.create(:visit) }
#   let(:estate) { visit.prison.estate }

#   VCR.configure do |c|
#     c.ignore_request do |request|
#       URI("https://api.notifications.service.gov.uk/v2/notifications/email")
#     end
#   end

#   describe '#update' do
#     subject do
#       put :update, params: {
#         id: visit.id,
#         visit: staff_response,
#         locale: 'en'
#       }
#     end

#     let(:staff_response) { { slot_granted: visit.slots.first.to_s } }

#     it_behaves_like 'disallows untrusted ips'

#     context 'when there is no logged in user' do
#       it { is_expected.not_to be_successful }
#     end

#     context 'when there is a logged in user' do
#       let(:user)                { create(:user) }
#       let(:nowish)              { Time.zone.now }
#       let(:processing_time_key) { "processing_time-#{visit.id}-#{user.id}" }

#       before do
#         login_user(user, current_estates: [estate])
#         request.cookies[processing_time_key] = nowish - 2.minutes
#       end

#       context 'when invalid' do
#         let(:staff_response) { { slot_granted: '' } }

#         it { is_expected.to render_template('show') }
#       end

#       context 'when valid' do
#         let(:staff_response) { { slot_granted: visit.slots.first.to_s, reference_no: 'none' } }
#         let(:google_tracker) { instance_double(GATracker) }

#         before do
#           expect(GATracker).to receive(:new).and_return(google_tracker)
#           expect(google_tracker).to receive(:send_processing_timing)
#           expect(google_tracker).to receive(:send_unexpected_rejection_event)
#           expect(google_tracker).to receive(:send_rejection_event)
#           expect(google_tracker).to receive(:send_booked_visit_event)
#         end

#         it { is_expected.to redirect_to(prison_inbox_path) }
#       end
#     end
#   end

#   describe '#show' do
#     let(:nowish) { Time.zone.now }
#     let(:user)   { create(:user) }

#     context 'with security' do
#       subject { get :show, params: { id: 1, locale: 'en' } }

#       it_behaves_like 'disallows untrusted ips'
#     end

#     context "when logged in" do
#       before do
#         travel_to nowish do
#           login_user(user, current_estates: [estate])
#           get :show, params: { id: visit.id, locale: 'en' }
#         end
#       end

#       it { expect(response).to render_template('show') }
#       it { expect(response).to be_successful }

#       context 'with a processable visit' do
#         let(:processing_time_key) { "processing_time-#{visit.id}-#{user.id}"  }
#         let(:parsed_cookie)       { cookies[processing_time_key] }

#         it "sets the visit processing time cookie" do
#           expect(parsed_cookie).to eq(nowish.to_i.to_s)
#         end
#       end
#     end

#     context "when logged out" do
#       before do get :show, params: { id: visit.id, locale: 'en' } end

#       it { expect(response).not_to be_successful }
#     end
#   end

#   describe '#confirm_nomis_cancelled' do
#     let(:cancellation) { FactoryBot.create(:cancellation) }
#     let(:visit) { cancellation.visit }

#     subject { post :nomis_cancelled, params: { id: visit.id, locale: 'en' } }

#     it_behaves_like 'disallows untrusted ips'

#     context 'when there is a user signed in' do
#       let(:user) { FactoryBot.create(:user) }

#       before do
#         login_user(user, current_estates: [estate])
#       end

#       it { is_expected.to redirect_to(prison_inbox_path) }
#     end

#     context "when signed out" do
#       it { is_expected.not_to be_successful }
#     end
#   end
# end
