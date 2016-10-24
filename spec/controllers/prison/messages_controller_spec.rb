require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::MessagesController do
  describe '#create' do
    subject do
      post :create, message: { body: message_body }, visit_id: visit.id
    end

    let(:prison) { FactoryGirl.create(:prison, estate: estate) }
    let(:visit) { FactoryGirl.create(:visit, prison: prison) }
    let(:user) { FactoryGirl.create(:user) }
    let(:estate) { FactoryGirl.create(:estate) }

    let(:message_body) { 'Hello' }

    before do
      request.env['HTTP_REFERER'] = '/previous/path'
    end

    it_behaves_like 'disallows untrusted ips'

    context "when logged in" do
      before do
        login_user(user, estate)
      end

      it 'creates a message' do
        expect {
          expect(subject).to redirect_to('/previous/path')
        }.to change { visit.reload.messages.count }.by(1)
      end

      context 'when invalid' do
        let(:message_body) { nil }

        it 'renders the visit show page' do
          expect {
            expect(subject).to render_template('prison/visits/show')
          }.to_not change { visit.reload.messages.count }
        end
      end
    end

    context "when logged out" do
      it { is_expected.to_not be_successful }
    end
  end
end
