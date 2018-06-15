require 'rails_helper'

RSpec.describe Cancellation, model: true do
  subject { FactoryBot.build(:cancellation) }

  describe 'validation' do
    context 'with empty strings' do
      before do
        subject.reasons = ['', described_class::PRISONER_VOS]
      end

      it { is_expected.to be_valid }
    end

    it 'enforces no more than one per visit' do
      cancellation = FactoryBot.create(:cancellation)
      expect {
        FactoryBot.create(:cancellation, visit: cancellation.visit)
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect {
        FactoryBot.create(:cancellation, visit_id: SecureRandom.uuid)
      }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end

    describe '#reasons' do
      context 'with rejection reasons' do
        before do
          subject.reasons = reasons
        end

        context 'when the reason does not exists' do
          let(:reasons) { ['invalid_reason'] }

          it 'for an invalid reason' do
            expect(subject).not_to be_valid
            expect(subject.errors.full_messages_for(:reasons)).to eq(
              ['Reasons invalid_reason is not in the list']
            )
          end
        end

        context 'when the reason exists' do
          let(:reasons) do
            described_class::REASONS[0..rand(described_class::REASONS.length - 1)]
          end

          it { is_expected.to be_valid }
        end
      end

      describe 'witout a reason' do
        before do
          subject.reasons.clear
          is_expected.to be_invalid
        end

        it 'has a meaning full transalated message' do
          errors = subject.errors[:reasons]
          expect(errors).to eq(['Please provide a cancellation reason'])
        end
      end
    end
  end
end
