require 'rails_helper'

RSpec.describe StaffNomisChecker do
  subject(:instance) { described_class.new(visit) }

  # Enabled for slot availability
  let(:prison)   { build_stubbed(:prison, name: 'Pentonville') }
  let(:visit)    { build_stubbed(:visit, prisoner: prisoner, prison: prison) }
  let(:prisoner) { build_stubbed(:prisoner) }
  let(:offender) { Nomis::Offender.new(id: prisoner.number) }

  describe 'When the API is disabled' do
    before { switch_off_api }

    describe '#prisoner_existance_status' do
      it { expect(subject.prisoner_existance_status).to eq('not_live') }
    end

    describe '#prisoner_availability_unknown?' do
      it { is_expected.to_not be_prisoner_availability_unknown }
    end

    describe '#slot_availability_unknown?' do
      it { is_expected.to_not be_slot_availability_unknown }
    end

    describe '#errors_for' do
      it { expect(subject.errors_for(visit.slots.first)).to be_empty }
    end
  end

  describe 'When the API is enabled' do

    describe '#prisoner_existance_status' do

      describe 'api is configured and the check is disabled for staff' do
        before do
          switch_off(:nomis_staff_prisoner_check_enabled)
        end

        it { expect(subject.prisoner_existance_status).to eq('not_live') }
      end

      describe 'when the nomis api is live' do
        let(:validator) do
          double(PrisonerValidation, valid?: true, errors: { base: errors })
        end

        before do
          mock_nomis_with(:lookup_active_offender, offender)
          mock_service_with(PrisonerValidation, validator)
        end

        describe 'and there are no errors' do
          let(:errors) { [] }

          it { expect(subject.prisoner_existance_status).to eq('valid') }
        end

        describe "and the error is 'unknown'" do
          let(:errors) { ['unknown'] }

          it { expect(subject.prisoner_existance_status).to eq('unknown') }
        end

        describe "and the error is 'prisoner_does_not_exist'" do
          let(:errors) { ['prisoner_does_not_exist'] }

          it { expect(subject.prisoner_existance_status).to eq('invalid') }
        end
      end
    end

    describe '#prisoner_details_incorrect?' do
      before do
        expect(instance).
          to receive(:prisoner_existance_status).
               and_return(prisoner_status)
      end

      context 'when the prisoner status is invalid' do
        let(:prisoner_status) { described_class::INVALID }

        it { is_expected.to be_prisoner_details_incorrect }
      end

      context 'when is anything else other than valid' do
        let(:prisoner_status) { false }

        it { is_expected.to_not be_prisoner_details_incorrect }
      end
    end

    describe '#prisoner_existance_error' do
      let(:offender) { Nomis::NullOffender.new(api_call_successful: true) }

      before do
        mock_nomis_with(:lookup_active_offender, offender)
      end

      it 'is the error from the prisoner validation' do
        expect(instance.prisoner_existance_error).to eq('prisoner_does_not_exist')
      end
    end

    describe '#prisoner_availability_unknown?' do
      context 'with NOMIS_STAFF_PRISONER_AVAILABILITY_ENABLED is disabled' do

        before do
          switch_off(:nomis_staff_prisoner_availability_enabled)
        end

        it { is_expected.to_not be_prisoner_availability_unknown }
      end

      context 'with NOMIS_STAFF_PRISONER_AVAILABILITY_ENABLED is enabled' do

        let(:prisoner_availability_validation) do
          double(PrisonerAvailabilityValidation,
                 valid?: false, unknown_result?: unknown_result)
        end

        before do
          mock_nomis_with(:lookup_active_offender, offender)
          mock_service_with(PrisonerAvailabilityValidation, prisoner_availability_validation)
        end

        context 'when the validator returns unknown' do
          let(:unknown_result) { true }

          it { is_expected.to be_prisoner_availability_unknown }
        end

        context 'when the validator returns not unknown' do
          let(:unknown_result) { false }

          it { is_expected.to_not be_prisoner_availability_unknown }
        end
      end
    end

    describe '#errors_for' do
      let(:slot) { visit.slots.first }

      context 'prisoner availability' do
        context 'when NOMIS_STAFF_PRISONER_AVAILABILITY_ENABLED' do

          context 'is disabled' do
            before do
              switch_off(:nomis_staff_prisoner_availability_enabled)
            end

            it { expect(subject.errors_for(slot)).to be_empty }
          end

          context 'is enabled' do
            before do
              switch_on(:nomis_staff_prisoner_availability_enabled)
              mock_nomis_with(:lookup_active_offender, offender)
            end

            context 'with a valid offender' do
              let(:offender) { Nomis::Offender.new(id: '1234') }

              let(:prisoner_availability_validator) do
                instance_double(PrisonerAvailabilityValidation, valid?: false, slot_errors: messages)
              end

              before do
                mock_service_with(PrisonerAvailabilityValidation, prisoner_availability_validator)
              end

              context 'with an error' do
                let(:messages) { [Nomis::PrisonerDateAvailability::BANNED] }

                it { expect(subject.errors_for(slot)).to eq(messages) }
              end

              context 'with no errors' do
                let(:messages) { [] }

                it { expect(subject.errors_for(slot)).to be_empty }
              end
            end

            context 'a null offender' do
              let(:offender) { Nomis::NullOffender.new }

              it { expect(subject.errors_for(slot)).to be_empty }
            end
          end
        end
      end

      context 'slot availability' do
        let(:offender) { Nomis::NullOffender.new }

        before do
          mock_nomis_with(:lookup_active_offender, offender)
        end

        context 'with NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED switched OFF' do
          before do
            switch_off :nomis_staff_slot_availability_enabled
          end

          it { expect(subject.errors_for(slot)).to be_empty }

          describe "and STAFF_PRISONS_WITH_SLOT_AVAILABILITY switched OFF for the visit's prison" do
            before do
              switch_feature_flag_with(:staff_prisons_with_slot_availability, [])
            end

            it { expect(subject.errors_for(slot)).to be_empty }
          end
        end

        context 'with NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED switched ON' do
          before do
            switch_on :nomis_staff_slot_availability_enabled
          end

          describe "and STAFF_PRISONS_WITH_SLOT_AVAILABILITY switched ON for the visit's prison" do
            let(:message)  { nil }
            let(:slot_availability_validation) do
              instance_double(SlotAvailabilityValidation, valid?: false, slot_error: message)
            end

            before do
              switch_feature_flag_with(:staff_prisons_with_slot_availability, %w[Pentonville Cardiff])
              mock_service_with(SlotAvailabilityValidation, slot_availability_validation)
            end

            context 'with no errors' do
              let(:message) { nil }

              it { expect(subject.errors_for(slot)).to be_empty}
            end

            context 'with an error' do
              let(:message) { SlotAvailabilityValidation::SLOT_NOT_AVAILABLE }

              it { expect(subject.errors_for(slot)).to eq([message]) }
            end
          end
        end
      end
    end

    describe '#slots_unavailable?' do
      subject { instance.slots_unavailable? }

      describe 'when the slots have expired' do
        before do
          now = Date.current
          allow(visit).
            to receive(:slots).
                 and_return([
                              ConcreteSlot.new(2015, 10, 5, 11, 30, 12, 30),
                              ConcreteSlot.new(now.year, now.month, now.day, 14, 30, 15, 30)
                            ])
        end

        it { is_expected.to eq(true) }
      end

      describe 'when the slots are unavailable' do
        before do
          allow(instance).
            to receive(:errors_for).
                 with(anything).
                 and_return([SlotAvailabilityValidation::SLOT_NOT_AVAILABLE])
        end

        it { is_expected.to eq(true) }
      end

      describe 'when a future slot is available' do
        let(:slot1) do
          date = Date.current + 3.days
          ConcreteSlot.new(date.year, date.month, date.day, 12, 0, 13, 0)
        end

        let(:slot2) do
          date = Date.current + 2.days
          ConcreteSlot.new(date.year, date.month, date.day, 12, 0, 13, 0)
        end

        let(:slot3) do
          date = Date.current - 2.days
          ConcreteSlot.new(date.year, date.month, date.day, 12, 0, 13, 0)
        end

        before do
          allow(visit).to receive(:slots).and_return([slot1, slot2, slot3])

          allow(instance).to receive(:errors_for).with(slot1).and_return([])

          allow(instance).
            to receive(:errors_for).
                 with(slot2).
                 and_return([SlotAvailabilityValidation::SLOT_NOT_AVAILABLE])
        end

        it { is_expected.to eq(false) }
      end
    end

    describe '#no_allowance?' do
      let(:slot) { ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0) }

      subject { instance.no_allowance?(slot) }

      before do
        expect(instance).to receive(:errors_for).with(slot).and_return(errors)
      end

      context 'when there is no vo error' do
        let(:errors) { [Nomis::PrisonerDateAvailability::OUT_OF_VO] }

        it { is_expected.to eq(true) }
      end

      context "when there isn't a no vo error" do
        let(:errors) { [] }

        it { is_expected.to eq(false) }
      end
    end

    describe '#prisoner_banned?' do
      let(:slot) { ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0) }

      subject { instance.prisoner_banned?(slot) }

      before do
        expect(instance).to receive(:errors_for).with(slot).and_return(errors)
      end

      context 'when there is a prisoner banned error' do
        let(:errors) { [Nomis::PrisonerDateAvailability::BANNED] }

        it { is_expected.to eq(true) }
      end

      context "when there isn't prisoner banned error" do
        let(:errors) { [] }

        it { is_expected.to eq(false) }
      end
    end

    describe '#prisoner_out_of_prison?' do
      let(:slot) { ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0) }

      subject { instance.prisoner_out_of_prison?(slot) }

      before do
        expect(instance).to receive(:errors_for).with(slot).and_return(errors)
      end

      context 'when there is a prisoner out of prison error' do
        let(:errors) { [Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT] }

        it { is_expected.to eq(true) }
      end

      context "when there isn't prisoner out of prison error" do
        let(:errors) { [] }

        it { is_expected.to eq(false) }
      end
    end

    describe '#contact_list_enabled?' do

      context 'when NOMIS_STAFF_PRISONER_CHECK_ENABLED is disabled' do
        before do
          switch_off(:nomis_staff_prisoner_check_enabled)
        end

        it { is_expected.to_not be_contact_list_enabled }
      end

      context 'when NOMIS_STAFF_PRISONER_CHECK_ENABLED is enabled' do
        before do
          switch_on(:nomis_staff_prisoner_check_enabled)
          switch_feature_flag_with(:staff_prisons_with_nomis_contact_list, contact_list_enabled_prisons)
        end

        context 'and the prison is in the comma separated list STAFF_PRISONS_WITH_NOMIS_CONTACT_LIST' do
          let(:contact_list_enabled_prisons) { [visit.prison_name] }

          it { is_expected.to be_contact_list_enabled }
        end

        context 'and the prison is not in the the comma separated list STAFF_PRISONS_WITH_NOMIS_CONTACT_LIST' do
          let(:contact_list_enabled_prisons) { [] }

          it { is_expected.to_not be_contact_list_enabled }
        end
      end
    end


    describe '#contact_list_unknown?' do

      context 'with NOMIS_STAFF_PRISONER_CHECK_ENABLED switched ON' do
        let(:contact_list_api_error) { false }
        let(:contact_list) do
          instance_double(PrisonerContactList, unknown_result?: contact_list_api_error)
        end

        context 'and the prison is in the comma separated list STAFF_PRISONS_WITH_NOMIS_CONTACT_LIST' do
          before do
            switch_on(:nomis_staff_prisoner_check_enabled)
            mock_nomis_with(:lookup_active_offender, offender)
            switch_feature_flag_with(:staff_prisons_with_nomis_contact_list, [visit.prison_name])
            mock_service_with(PrisonerContactList, contact_list)
          end

          it { is_expected.to_not be_contact_list_unknown }

          context 'and the contact list returns an API error' do
            let(:contact_list_api_error) { true }

            it { is_expected.to be_contact_list_unknown }
          end
        end

        context 'and the prison is in the comma separated list STAFF_PRISONS_WITH_NOMIS_CONTACT_LIST' do
          it ''
        end
      end

      context 'with NOMIS_STAFF_PRISONER_CHECK_ENABLED switched OFF' do
        before do
          switch_off :nomis_staff_prisoner_check_enabled
        end

        it { is_expected.to_not be_contact_list_unknown }
      end
    end

    describe '#approved_contacts' do
      let(:approved_contacts) { double }
      let(:contact_list) do
        instance_double(PrisonerContactList, approved: approved_contacts)
      end

      before do
        mock_nomis_with(:lookup_active_offender, offender)
        mock_service_with(PrisonerContactList, contact_list)
      end

      it 'returns the prisoner approved contacts' do
        expect(subject.approved_contacts).to eq(approved_contacts)
      end
    end
  end
end
