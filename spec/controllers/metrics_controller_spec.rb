require 'rails_helper'

RSpec.describe MetricsController, type: :controller do
  describe 'index' do
    let(:range) { nil }
    let(:params) { { range:, locale: 'en' } }

    subject { get :index, params: }

    context 'with no range' do
      let(:range) { 'all_time' }

      it { is_expected.to be_successful }
    end

    context "with a range" do
      let(:range) { 'weekly' }

      before do
        create(:visit, created_at: 1.week.ago)
        create(:rejected_visit, created_at: 1.year.ago)
      end

      it { is_expected.to be_successful }
    end
  end

  describe 'summary' do
    let(:prison) { create(:prison) }

    subject { get :summary, params: { prison_id: prison.to_param, locale: 'en' } }

    it { is_expected.to be_successful }
  end

  describe '#send_confirmed_bookings' do
    let(:user) { create(:user) }
    let(:mail) { double(Mail::Message, deliver_later: nil) }

    before do
      login_user(user, current_estates: [create(:estate)])
    end

    subject { get :send_confirmed_bookings, params: { locale: 'en' } }

    it 'enqueues a confirmed bookings csv email' do
      expect(AdminMailer).to receive(:confirmed_bookings).and_return(mail)
      expect(mail).to receive(:deliver_later)

      expect(subject).to redirect_to(metrics_path)
    end
  end
end
