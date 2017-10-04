require 'rails_helper'

RSpec.describe CancellationDecorator do
  let!(:visit) { create(:cancelled_visit) }
  let(:cancellation) { create(:cancellation, visit: visit) }

  subject { described_class.decorate(cancellation) }

  describe '#formatted_reasons' do
    before do
      cancellation.reasons = reasons
    end

    context 'containing child protection' do
      let(:reasons) { [Cancellation::CHILD_PROTECTION_ISSUES] }

      it 'has the correct explanation' do
        expect(
          subject.formatted_reasons.map(&:explanation)
        ).to eq([
          "<p>We have cancelled your visit due to restrictions around this prisoner.<\/p>\n<p\>You may be able to visit them at a later date.<\/p>"
        ])
      end
    end

    context 'containing prisoner non association' do
      let(:reasons) { [Cancellation::PRISONER_NON_ASSOCIATION] }

      it 'has the correct explanation' do
        expect(
          subject.formatted_reasons.map(&:explanation)
        ).to eq([
          "<p>We have cancelled your visit due to restrictions around this prisoner.<\/p>\n<p>You may be able to visit them at a later date.</p>"
        ])
      end
    end

    context 'containing visitor banned' do
      let(:reasons) { [Cancellation::VISITOR_BANNED] }

      it 'has the correct explanation' do
        expect(
          subject.formatted_reasons.map(&:explanation)
        ).to eq([
          "<p>We have cancelled your visit because you have been banned from visiting this prison.<\/p>\n<p>We have sent you a letter explaining why we took this decision and giving you further details.</p>"
        ])
      end
    end

    context 'containing both a no association and another non-restriction reason' do
      let(:reasons) do
        [
          Cancellation::PRISONER_NON_ASSOCIATION,
          Cancellation::CHILD_PROTECTION_ISSUES
        ]
      end

      it 'has a restricted and another restricted reasons' do
        expect(subject.formatted_reasons.map(&:explanation)).
          to contain_exactly("<p>We have cancelled your visit due to restrictions around this prisoner.<\/p>\n<p>You may be able to visit them at a later date.<\/p>")
      end
    end
  end
end
