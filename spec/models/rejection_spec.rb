require 'rails_helper'

RSpec.describe Rejection, model: true do
  subject do
    described_class.new(
      reasons: reasons,
      allowance_renews_on: allowance_renews_on,
      rejection_reason_detail: rejection_reason_detail
    )
  end

  let(:reasons) { [Rejection::SLOT_UNAVAILABLE] }
  let(:rejection_reason_detail) { nil }
  let(:allowance_renews_on) do
    { day: '12', month: '11', year:  '2017' }
  end

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

    context 'when rejecting a visit for any other reason' do
      let(:reasons) { [described_class::OTHER_REJECTION_REASON] }

      context 'with an explanation' do
        let(:rejection_reason_detail) { 'some reason' }

        it { is_expected.to be_valid }
      end

      context 'with no explanation' do
        let(:rejection_reason_detail) { nil }

        it { is_expected.to be_invalid }
      end
    end

    context "when rejecting a visit for any reason except 'other' and there is text in other reason field" do
      let(:reasons) { [Rejection::SLOT_UNAVAILABLE] }
      let(:detail) { 'Some reason' }

      before do
        visit = create(:visit)
        subject.assign_attributes(visit_id: visit.id, reasons: reasons, rejection_reason_detail: detail)
      end

      it 'does not save the text from the rejection reason field to the database' do
        expect { subject.save! }.to change(subject, :rejection_reason_detail).to(nil)
      end
    end

    context 'when allowance renews on given date' do
      context 'when rejected for no allowance' do
        let(:reasons) { [described_class::NO_ALLOWANCE] }

        context 'with a valid date' do
          it 'is valid' do
            expect(subject).to be_valid
          end
        end

        context 'with a null date' do
          let(:allowance_renews_on) { nil }

          it 'is valid' do
            expect(subject).to be_valid
          end
        end

        context 'with an invalid accessible date' do
          let(:allowance_renews_on_attributes) do
            {
              'allowance_renews_on(1i)' => '',
              'allowance_renews_on(2i)' => '',
              'allowance_renews_on(3i)' => '1'
            }
          end

          it 'is invalid' do
            subject.assign_attributes(allowance_renews_on_attributes)
            expect(subject).to be_invalid
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

      context 'when the reason does not exists' do
        let(:reasons) { ['invalid_reason'] }

        it 'for an ivalid reason' do
          expect(subject).not_to be_valid
          expect(subject.errors.full_messages_for(:reasons)).to eq(
            ['Reasons invalid_reason is not in the list']
          )
        end
      end

      it 'returns an array of reasons' do
        expect(subject.reasons).to eq(reasons)
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
