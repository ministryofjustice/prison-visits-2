require 'rails_helper'

RSpec.describe Cancellation, model: true do
  subject { FactoryGirl.build(:cancellation) }

  describe 'validation' do
    it 'enforces no more than one per visit' do
      cancellation = FactoryGirl.create(:cancellation)
      expect {
        FactoryGirl.create(:cancellation, visit: cancellation.visit)
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect {
        FactoryGirl.create(:cancellation, visit_id: SecureRandom.uuid)
      }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end

    it 'checks the reason code is allowed' do
      cancellation = FactoryGirl.build_stubbed(:cancellation)
      cancellation.reason = 'random'
      expect(cancellation).to be_invalid
      expect(cancellation.errors[:reason]).to be_present
    end

    describe '#reasons' do
      context 'with rejection reasons' do
        before do
          subject.reasons = reasons
        end

        context 'and the reason does not exists' do
          let(:reasons) { ['invalid_reason'] }

          it 'for an invalid reason' do
            expect(subject).not_to be_valid
            expect(subject.errors.full_messages_for(:reasons)).to eq(
              ['Reasons invalid_reason is not in the list']
            )
          end
        end

        context 'and the reason exists' do
          let(:reasons) do
            described_class::REASONS[0..rand(described_class::REASONS.length - 1)]
          end

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
