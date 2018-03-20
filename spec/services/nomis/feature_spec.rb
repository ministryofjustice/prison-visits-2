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

  describe 'when the api is enabled' do
    it { expect(described_class).not_to be_offender_restrictions_enabled }

    context 'with the prisoner check enabled' do
      context 'with the offender restrictions enabled' do
        before do
          switch_on :nomis_staff_offender_restrictions_enabled
        end

        it { expect(described_class).to be_offender_restrictions_enabled }
      end

      context 'with the offender restrictions disabled' do
        before do
          switch_off :nomis_staff_offender_restrictions_enabled
        end

        it { expect(described_class).not_to be_offender_restrictions_enabled }
      end
    end
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

    context 'when the slot availability flag is enabled and the visit prison is not on the list' do
      before do
        switch_on :nomis_staff_slot_availability_enabled
        switch_feature_flag_with(:staff_prisons_with_slot_availability, [prison_name])
      end

      it { expect(described_class.slot_availability_enabled?(prison_name)).to eq(true) }
    end
  end

  describe '.book_to_nomis_enabled?' do
    context 'when the book to nomis flag is disabled' do
      before do
        switch_off :nomis_staff_book_to_nomis_enabled
      end

      it { expect(described_class.book_to_nomis_enabled?(anything)).to eq(false) }
    end

    context 'when the book to nomis flag is enabled' do
      before do
        switch_on :nomis_staff_book_to_nomis_enabled
      end

      context 'when the visit prison is not on the list' do
        before do
          switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [])
        end

        it { expect(described_class.book_to_nomis_enabled?(prison_name)).to eq(false) }
      end

      context 'when the visit prison is on the list' do
        before do
          switch_feature_flag_with(:staff_prisons_with_book_to_nomis, [prison_name])
        end

        it { expect(described_class.book_to_nomis_enabled?(prison_name)).to eq(true) }
      end
    end
  end

  describe '.offender_restrictions_info_enabled?' do
    context 'with offender restrictions disabled' do
      before do
        switch_off :nomis_staff_offender_restrictions_enabled
      end

      it { expect(described_class.offender_restrictions_info_enabled?(anything)).to eq(false) }
    end

    context 'with offender restrictions enabled' do
      before do
        switch_on :nomis_staff_offender_restrictions_enabled
      end

      context 'when the prison is not on the list for restrictions info' do
        before do
          switch_feature_flag_with(:staff_prisons_with_prisoner_restrictions_info, [])
        end

        it { expect(described_class.offender_restrictions_info_enabled?(anything)).to eq(false) }
      end

      context 'when the prison is not the list for restrictions info' do
        before do
          switch_feature_flag_with(:staff_prisons_with_prisoner_restrictions_info, [prison_name])
        end

        it { expect(described_class.offender_restrictions_info_enabled?(prison_name)).to eq(true) }
      end
    end
  end

  describe '.internal_location_enabled?' do
    context 'when the flag is enabled' do
      before do
        switch_on :nomis_internal_location_enabled
      end

      it { is_expected.to be_internal_location_enabled }
    end

    context 'when the flag is disabled' do
      before do
        switch_off :nomis_internal_location_enabled
      end

      it { is_expected.not_to be_internal_location_enabled }
    end
  end

  describe '.iep_level_enabled?' do
    context 'when the flag is enabled' do
      before do
        switch_on :nomis_iep_level_enabled
      end

      it { is_expected.to be_iep_level_enabled }
    end

    context 'when the flag is disabled' do
      before do
        switch_off :nomis_iep_level_enabled
      end

      it { is_expected.not_to be_iep_level_enabled }
    end
  end

  describe '.sentence_status_enabled?' do
    context 'when the flag is enabled' do
      before do
        switch_on :nomis_sentence_status_enabled
      end

      it { is_expected.to be_sentence_status_enabled }
    end

    context 'when the flag is disabled' do
      before do
        switch_off :nomis_sentence_status_enabled
      end

      it { is_expected.not_to be_sentence_status_enabled }
    end
  end
end
