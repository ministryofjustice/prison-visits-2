require 'rails_helper'

RSpec.describe Message, type: :model do
  describe '.create_and_send_email' do
    subject { described_class.create_and_send_email(attrs) }

    let(:visit) { create(:visit) }
    let(:user) { FactoryBot.create(:user) }

    let(:attrs) do
      {
        visit: visit,
        user: user,
        body: message_body
      }
    end

    context 'when is a valid message' do
      let(:message_body) { 'Hello' }

      it 'creates a message and sends it' do
        mail = double('email', deliver_later: true)

        expect(VisitorMailer)
          .to receive(:one_off_message).with(instance_of(described_class))
          .and_return(mail)

        expect { subject }.to change { visit.messages.count }.by(1)
      end
    end

    context 'when is not a valid message' do
      let(:message_body) { nil }

      it 'does not create or send a message' do
        expect(VisitorMailer).not_to receive(:one_off_message)
        expect { subject }.not_to change(visit, :messages)
      end
    end
  end
end
