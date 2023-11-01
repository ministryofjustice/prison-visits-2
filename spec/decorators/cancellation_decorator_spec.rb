require 'rails_helper'

RSpec.describe CancellationDecorator do
  let!(:visit) { create(:cancelled_visit) }
  let(:cancellation) { create(:cancellation, visit: visit) }

  subject { described_class.decorate(cancellation) }

  describe '#formatted_reasons' do
    before do
      cancellation.reasons = reasons
    end

    context 'when containing child protection' do
      let(:reasons) { [Cancellation::CHILD_PROTECTION_ISSUES] }

      it 'has the correct explanation' do
        expect(
          subject.formatted_reasons.map(&:explanation)
        ).to eq([
          "there are restrictions around this prisoner. You may be able to visit them at a later date."
        ])
      end
    end

    context 'when containing prisoner non association' do
      let(:reasons) { [Cancellation::PRISONER_NON_ASSOCIATION] }

      it 'has the correct explanation' do
        expect(
          subject.formatted_reasons.map(&:explanation)
        ).to eq([
          "there are restrictions around this prisoner. You may be able to visit them at a later date."
        ])
      end
    end

    context 'when containing visitor banned' do
      let(:reasons) { [Cancellation::VISITOR_BANNED] }

      it 'has the correct explanation' do
        expect(
          subject.formatted_reasons.map(&:explanation)
        ).to eq([
          "you have been banned from visiting this prison. We’ve sent you a letter with further details."
        ])
      end
    end

    context 'when containing both a no association and another non-restriction reason' do
      let(:reasons) do
        [
          Cancellation::PRISONER_NON_ASSOCIATION,
          Cancellation::CHILD_PROTECTION_ISSUES
        ]
      end

      it 'has a restricted and another restricted reasons' do
        expect(subject.formatted_reasons.map(&:explanation))
          .to contain_exactly("there are restrictions around this prisoner. You may be able to visit them at a later date.")
      end
    end
  end
end
