require 'rails_helper'

RSpec.describe Nomis::Feature do
  subject { described_class }

  let(:prison_name) { 'Pentonville' }

  describe 'when the api is disabled' do
    before do
      switch_off_api
    end

    it { expect(described_class.slot_availability_enabled?(anything)).to eq(false) }
  end

  describe '.slot_availability_enabled?' do
    context 'when the slot availability flag is disabled' do
      before do
        switch_off :nomis_staff_slot_availability_enabled
      end

      it { expect(described_class.slot_availability_enabled?(anything)).to eq(false) }
    end

    context 'when the slot availability flag is enabled and the visit prison is not on the list' do
      before do
        switch_on :nomis_staff_slot_availability_enabled
        switch_feature_flag_with(:staff_prisons_with_slot_availability, [])
      end

      it { expect(described_class.slot_availability_enabled?(prison_name)).to eq(false) }
    end

    context 'when the slot availability flag is enabled and the visit prison is on the list' do
      before do
        switch_on :nomis_staff_slot_availability_enabled
        switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison_name])
      end

      it { expect(described_class.slot_availability_enabled?(prison_name)).to eq(true) }
    end
  end
end
