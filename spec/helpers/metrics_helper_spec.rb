require 'rails_helper'

RSpec.describe MetricsHelper do
  describe '.image_for_performance_score' do
    subject { helper.image_for_performance_score(score) }

    context 'when between 0 and 3' do
      let(:score) { 1.day }

      it { is_expected.to match(/green-dot-\w+\.png/) }
    end

    context 'when between 3 and 4' do
      let(:score) { 3.1.days }

      it { is_expected.to match(/amber-dot-\w+\.png/) }
    end

    context 'when bigger than 4' do
      let(:score) { 4.1.days }

      it { is_expected.to match(/red-dot-\w+\.png/) }
    end
  end
end
