require 'rails_helper'

RSpec.describe NullStaffNomisChecker do
  describe '#prisoner_existance_status' do
    it { expect(subject.prisoner_existance_status).to eq(described_class::NO_CHECK_REQUIRED) }
  end

  describe '#prisoner_existance_error' do
    it { expect(subject.prisoner_existance_error).to be_nil }
  end

  describe '#prisoner_availability_unknown?' do
    it { expect(subject.prisoner_availability_unknown?).to eq(false) }
  end

  describe '#errors_for' do
    it { expect(subject.errors_for(anything)).to be_empty }
  end

  describe '#prisoner_availability_enabled?' do
    it { expect(subject.prisoner_availability_enabled?).to eq(false) }
  end
end
