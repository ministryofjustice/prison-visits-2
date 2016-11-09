require 'rails_helper'

RSpec.describe Rejection, model: true do
  subject { described_class.new(reasons: [Rejection::SLOT_UNAVAILABLE]) }

  it { is_expected.to be_valid }

  describe 'validation' do
    it 'enforces no more than one per visit' do
      visit = create(:visit)
      reject_visit visit
      expect {
        described_class.create!(visit: visit, reasons: [described_class::NOT_ON_THE_LIST])
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect {
        described_class.create!(visit_id: SecureRandom.uuid, reasons: [described_class::NOT_ON_THE_LIST])
      }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end
  end

  describe '#reasons' do
    context 'with rejection reasons' do
      let(:reasons) do
        described_class::REASONS[0..rand(described_class::REASONS.length - 1)]
      end

      before do
        subject.reasons = reasons
      end

      context 'and the reason does not exists' do
        let(:reasons) { ['invalid_reason'] }

        it 'for an ivalid reason' do
          expect(subject).to_not be_valid
          expect(subject.errors.full_messages_for(:reasons)).to eq(
            ['Reasons invalid_reason is not in the list']
          )
        end
      end

      context 'and the reason does not exists' do
        it 'returns an of reasons' do
          expect(subject.reasons).to eq(reasons)
        end
      end
    end
  end

  describe 'allowance_will_renew?' do
    it 'is true if there is an allowance_renews_on date' do
      subject.allowance_renews_on = Date.current
      expect(subject).to be_allowance_will_renew
    end

    it 'is false if these is no allowance_renews_on date' do
      subject.allowance_renews_on = ''
      expect(subject).not_to be_allowance_will_renew
    end
  end
end
