require 'rails_helper'

RSpec.describe Visitor do
  subject(:instance) { described_class.new }

  it { is_expected.to belong_to(:visit) }
  it { is_expected.to validate_presence_of(:visit) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:date_of_birth) }

  describe '#allowed?' do
    subject { instance.allowed? }

    before do
      instance.not_on_list = not_on_list
      instance.banned = banned
    end

    context 'when not banned or is the contact list' do
      let(:not_on_list) { false }
      let(:banned) { false }

      it { is_expected.to eq(true) }
    end

    context 'when banned' do
      let(:not_on_list) { false }
      let(:banned) { true }

      it { is_expected.to eq(false) }
    end

    context 'when not in the contact list' do
      let(:not_on_list) { true }
      let(:banned) { false }

      it { is_expected.to eq(false) }
    end
  end

  describe '#status' do
    subject { instance.status }

    context 'when is allowed' do
      it { is_expected.to eq('allowed') }
    end

    context 'when is banned' do
      before do
        instance.banned = true
      end

      it { is_expected.to eq('banned') }
    end

    context 'when is not on the list' do
      before do
        instance.not_on_list = true
      end

      it { is_expected.to eq('not on list') }
    end
  end
end
