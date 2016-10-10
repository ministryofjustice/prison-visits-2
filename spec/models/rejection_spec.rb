require 'rails_helper'

RSpec.describe Rejection, model: true do
  describe 'validation' do
    it 'enforces no more than one per visit' do
      visit = create(:visit)
      create(:rejection, visit: visit)
      expect {
        create(:rejection, visit: visit)
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect {
        create(:rejection, visit_id: SecureRandom.uuid)
      }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end
  end

  describe '#reason' do
    let(:reason) { described_class::REASONS.sample }
    before do
      subject.update!(reason: reason, visit: create(:visit))
    end

    it 'copies the reason to the reasons array' do
      expect(subject.reasons).to eq([reason])
    end
  end

  describe '#reasons' do
    context 'without rejection reason' do
      it 'returns an empty array' do
        expect(subject.reasons).to eq([])
      end
    end

    context 'with rejection reasons' do
      let(:reasons) do
        described_class::REASONS[0..rand(described_class::REASONS.length - 1)]
      end

      before do
        subject.reasons = reasons
        subject.reason = reasons.first
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

  describe 'privileged_allowance_available?' do
    it 'is true if there is a privileged_allowance_expires_on date' do
      subject.privileged_allowance_expires_on = Time.zone.today + 1
      expect(subject).to be_privileged_allowance_available
    end

    it 'is false if these is no privileged_allowance_expires_on date' do
      subject.privileged_allowance_expires_on = ''
      expect(subject).not_to be_privileged_allowance_available
    end
  end

  describe 'allowance_will_renew?' do
    it 'is true if there is an allowance_renews_on date' do
      subject.allowance_renews_on = Time.zone.today + 1
      expect(subject).to be_allowance_will_renew
    end

    it 'is false if these is no allowance_renews_on date' do
      subject.allowance_renews_on = ''
      expect(subject).not_to be_allowance_will_renew
    end
  end
end
