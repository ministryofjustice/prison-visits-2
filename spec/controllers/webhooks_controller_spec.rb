require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe "#email" do
    let(:charsets) do
      { from: 'utf-8', to: 'utf-8', subject: 'utf-8', text: 'utf-8' }.to_json
    end
    let(:from) { 'default <default@example.com>' }
    let(:params) do
      {
        auth: auth,
        to: 'no-reply@example.com',
        from: from,
        subject: "A visit",
        text: "Some text",
        charsets: charsets,
        locale: 'en'
      }
    end

    subject { post :email, params }

    context "when authorized" do
      let(:auth) { Rails.configuration.webhook_auth_key }

      context "from the visitor" do
        let(:from) { 'John Doe <john@example.com>' }

        it 'sends a reminder that the inbox is unattended' do
          expect(VisitorMailer).
            to receive(:autorespond).
            with('john@example.com').
            and_call_original
          is_expected.to be_successful
        end
      end

      context "from a prison" do
        let(:from) { 'HMP Prison <prison@hmps.gsi.gov.uk>' }

        it 'sends a reminder that the inbox is unattended' do
          expect(PrisonMailer).
            to receive(:autorespond).
            with('prison@hmps.gsi.gov.uk').
            and_call_original

          is_expected.to be_successful
        end
      end
    end

    context "when unathorized" do
      let(:auth) { 'incorrect key' }

      it { is_expected.to be_forbidden }
    end
  end
end
