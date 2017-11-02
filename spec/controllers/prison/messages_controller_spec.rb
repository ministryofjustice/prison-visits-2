require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::MessagesController do
  describe '#create' do
    subject do
      post :create, params: { message: { body: message_body }, visit_id: visit.id }
    end

    let(:prison) { FactoryBot.create(:prison, estate: estate) }
    let(:visit) { FactoryBot.create(:visit, prison: prison) }
    let(:user) { FactoryBot.create(:user) }
    let(:estate) { FactoryBot.create(:estate) }

    let(:message_body) { 'Hello' }

    it_behaves_like 'disallows untrusted ips'

    context "when logged in" do
      before do
        login_user(user, current_estates: [estate])
      end

      it 'creates a message' do
        expect {
          expect(subject).to redirect_to(prison_visit_path(visit))
        }.to change { visit.reload.messages.count }.by(1)
      end

      context 'when invalid' do
        let(:message_body) { nil }

        it 'renders the visit show page' do
          expect {
            expect(subject).to render_template('prison/visits/show')
          }.not_to change { visit.reload.messages.count }
        end
      end
    end

    context "when logged out" do
      it { is_expected.not_to be_successful }
    end
  end
end
