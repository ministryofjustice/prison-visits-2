require 'rails_helper'

RSpec.describe Nomis::ContactRestriction do
  let(:type) { { code: "BAN", desc: "Banned" } }
  let(:effective_date) { 3.days.ago.to_date }
  let(:expiry_date) { nil }

  subject(:instance) do
    described_class.new(type: type,
                        effective_date: effective_date,
                        expiry_date: expiry_date)
  end

  describe '#banned?' do
    subject { instance.banned? }

    context 'with a banned restriction type' do
      let(:type) { { code: "BAN", desc: "Banned" } }
      it { is_expected.to eq(true) }
    end

    context 'with not a banned restriction type ' do
      let(:type) { { code: "CLO", desc: "Closed" } }
      it { is_expected.to eq(false) }
    end
  end
end
