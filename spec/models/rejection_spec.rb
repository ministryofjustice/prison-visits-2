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

    context 'when allowance will renew' do
      before do
        subject.reasons << Rejection::NO_ALLOWANCE
      end

      context 'validates the allowance renewal date' do
        before do
          subject.allowance_will_renew = '1'
        end

        context 'with a date set' do
          before do
            subject.allowance_renews_on = 1.day.from_now
          end

          it { is_expected.to be_valid }
        end

        context 'without a date set' do
          before do
            subject.allowance_renews_on = { day: '', month: '', year: '' }
            is_expected.to be_invalid
          end

          it 'has an error' do
            expect(subject.errors.full_messages).to eq(['Allowance renews on is invalid'])
          end
        end

        context 'with an erroneous date' do
          let(:date_hash)      { { day: '42', month: '42', year: '42' } }
          let(:uncoerced_date) { UncoercedDate.new(date_hash) }
          before do
            subject.allowance_renews_on = date_hash
          end
          it { is_expected.to be_invalid }

          it 'preserves the set date' do
            expect(subject.allowance_renews_on).to eq(date_hash)
          end
        end
      end
    end

    context 'when privileged allowance expires' do
      before do
        subject.reasons << described_class::NO_ALLOWANCE
      end
      context 'validates the privileged allowance expiry date' do
        before do
          subject.privileged_allowance_available = '1'
        end

        context 'with a date set' do
          before do
            subject.privileged_allowance_expires_on = { day: 01, month: 02, year: 2018 }
          end

          it { is_expected.to be_valid }
        end

        context 'without a date set' do
          before do
            subject.privileged_allowance_expires_on = { day: '', month: '', year: '' }
            is_expected.to_not be_valid
          end

          it 'has an error' do
            expect(subject.errors.full_messages).to eq(['Privileged allowance expires on is invalid'])
          end
        end

        context 'with an erroneous date' do
          let(:date_hash) { { day: '42', month: '42', year: '42' } }
          let(:uncoerced_date) { UncoercedDate.new(date_hash) }

          before do
            subject.privileged_allowance_expires_on = date_hash
          end

          it { is_expected.to be_invalid }

          it 'preserves the set date' do
            expect(subject.privileged_allowance_expires_on).to eq(date_hash)
          end
        end
      end
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

  describe '#allowance_renews_on=' do
    context 'when given a hash' do
      let(:dayish) { { year: '2100', month: '11', day: '30' } }
      it 'is cast as a date' do
        expect {
          subject.allowance_renews_on = dayish
        }.to change { subject.allowance_renews_on }.from(nil).to(Date.new(*dayish.values_at(:year, :month, :day).map(&:to_i)))
      end
    end
  end

  describe '#allowance_renews_on=' do
    context 'when given a hash' do
      let(:dayish) { { year: '2100', month: '11', day: '30' } }
      it 'is cast as a date' do
        expect {
          subject.allowance_renews_on = dayish
        }.to change { subject.allowance_renews_on }.from(nil).to(Date.new(*dayish.values_at(:year, :month, :day).map(&:to_i)))
      end
    end
  end

  describe '#privileged_allowance_expires_on=' do
    context 'when given a hash' do
      let(:dayish) { { year: '2100', month: '11', day: '30' } }
      it 'is cast as a date' do
        expect {
          subject.privileged_allowance_expires_on = dayish
        }.to change {
          subject.privileged_allowance_expires_on
        }.from(nil).to(Date.new(*dayish.values_at(:year, :month, :day).map(&:to_i)))
      end
    end
  end
end
