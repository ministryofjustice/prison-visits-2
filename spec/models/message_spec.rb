require 'rails_helper'

RSpec.describe Message, type: :model do
  it 'has a nonunique visit lookup index' do
    index = described_class.connection.indexes(described_class.table_name).find { |definition|
      definition.name == 'index_messages_on_visit_id'
    }

    expect(index).to have_attributes(columns: ['visit_id'], unique: false, where: nil)
  end

  describe '.create_and_send_email' do
    subject { described_class.create_and_send_email(attrs) }

    let(:visit) { create(:visit) }
    let(:user) { FactoryBot.create(:user) }

    let(:attrs) do
      {
        visit:,
        user:,
        body: message_body
      }
    end

    context 'when is a valid message' do
      let(:message_body) { 'Hello' }

      it 'creates a message' do
        expect { subject }.to change { visit.messages.count }.by(1)
      end
    end

    context 'when is not a valid message' do
      let(:message_body) { nil }

      it 'does not create a message' do
        expect { subject }.not_to change(visit, :messages)
      end
    end
  end
end
