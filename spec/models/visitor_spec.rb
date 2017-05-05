require 'rails_helper'

RSpec.describe Visitor do
  subject(:instance) { described_class.new }

  it { is_expected.to belong_to(:visit) }
  it { is_expected.to validate_presence_of(:visit) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:date_of_birth) }

  # describe 'validation' do
  #   context 'when not banned an banned_until set' do
  #     before do
  #       instance.banned = false
  #       instance.banned_until = Date.tomorrow
  #     end

  #     it { is_expected.not_to be_valid }
  #   end

  #   context 'when it is banned and is banned until yesterday' do
  #     before do
  #       instance.banned = true
  #       instance.banned_until = Date.yesterday
  #     end

  #     it { is_expected.not_to be_valid }
  #   end

  #   context 'when the banned until date is invalid' do
  #     before do
  #       instance.banned = true
  #       instance.banned_until = banned_until
  #     end

  #     context 'with a bogus date' do
  #       let(:banned_until) { { day: 30, month: 11, year: 1.year.from_now.year } }

  #       it { is_expected.not_to be_valid }
  #     end

  #     context 'with a date missing the year' do
  #       let(:banned_until) { { day: 30, month: 11, year: nil } }

  #       it { is_expected.not_to be_valid }
  #     end
  #   end
  # end

  # describe '#banned_until?' do
  #   subject { instance.banned_until? }

  #   before do
  #     instance.banned_until = banned_until
  #   end

  #   context 'with a valid date' do
  #     let(:banned_until) { Date.current }
  #     it { is_expected.to eq(true) }
  #   end

  #   context 'with an invalid date' do
  #     let(:banned_until) { { day: '1', month: '1', year: nil } }
  #     it { is_expected.to eq(false) }
  #   end

  #   context 'with a blank' do
  #     let(:banned_until) { '' }
  #     it { is_expected.to eq(false) }
  #   end
  # end

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
