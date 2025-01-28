require 'rails_helper'

RSpec.describe Rejection::Reason, :model do
  subject { described_class.new(explanation:) }

  let(:explanation) { 'prisoner has a restriction' }

  context 'when there is another reason with the same explanation' do
    let(:second_reason) { described_class.new(explanation:) }

    it { is_expected.to eql(second_reason) }

    it { expect(subject.hash).to eq(second_reason.hash) }
  end

  context 'when there is another reason with a different explanation' do
    let(:second_reason) { described_class.new(explanation: 'external_movement') }

    it { is_expected.not_to eql(second_reason) }

    it { expect(subject.hash).not_to eq(second_reason.hash) }
  end
end
