require 'rails_helper'
require 'human_readable_id'

RSpec.describe HumanReadableId do
  describe '.update_unique_id' do
    subject { described_class.update_unique_id(Visit, visit.id, :human_id) }

    let(:visit) { FactoryBot.create(:visit, human_id: nil) }

    it 'generates and updates the record with a new id' do
      expect { subject }.to change { visit.reload.human_id }
    end

    context 'when an id has already been saved to the DB' do
      before do
        described_class.update_unique_id(Visit, visit.id, :human_id)
      end

      it 'does not override the previous id' do
        expect { subject }.not_to change { visit.reload.human_id }
      end
    end

    context 'when a duplicate id is generated' do
      let(:other_visit) { FactoryBot.create(:visit, human_id: nil) }

      before do
        described_class.update_unique_id(Visit, other_visit.id, :human_id)

        expect(Base32::Crockford)
          .to receive(:encode)
          .and_return(other_visit.reload.human_id, 'unique_id')
      end

      it 'retries until a unique id is found' do
        expect { subject }
          .to change { visit.reload.human_id }
          .to('unique_id')
      end
    end
  end
end
