require 'rails_helper'

RSpec.describe StaffNomisChecker do
  subject { described_class.new(visit) }

  # Enabled for slot availability
  let(:prison)   { build_stubbed(:prison, name: 'Pentonville') }
  let(:visit)    { build_stubbed(:visit, prisoner: prisoner, prison: prison) }
  let(:prisoner) { build_stubbed(:prisoner) }
  let(:offender) { Nomis::Offender.new(id: prisoner.number, noms_id: 'some_noms_id') }

  describe 'When the API is disabled' do
    before do
      switch_off_api
    end

    describe '#prisoner_availability_unknown?' do
      it { is_expected.to be_prisoner_availability_unknown }
    end

    describe '#slot_availability_unknown?' do
      it { is_expected.not_to be_slot_availability_unknown }
    end

    describe '#prisoner_restrictions_unknown?' do
      it { is_expected.not_to be_prisoner_restrictions_unknown }
    end

    describe '#errors_for' do
      it { expect(subject.errors_for(visit.slots.first)).to be_empty }
    end

    describe '#offender' do
      it { expect(subject.offender).to be_instance_of(Nomis::NullOffender) }
    end
  end

  describe '#prisoner_availability_unknown?' do
    let(:prisoner_availability_validation) do
      instance_double(PrisonerAvailabilityValidation,
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

      it { is_expected.not_to be_prisoner_availability_unknown }
    end
  end

  describe '#errors_for' do
    let(:slot) { visit.slots.first }

    context 'with prisoner availability' do
      before do
        switch_off(:nomis_staff_prisoner_check_enabled)
      end

      context 'when the api is disabled' do
        before do
          switch_off_api
        end

        it { expect(subject.errors_for(slot)).to be_empty }
      end

      context 'when the api is enabled' do
        context 'with a valid offender' do
          let(:prisoner_availability_validator) do
            instance_double(PrisonerAvailabilityValidation, valid?: false, slot_errors: messages)
          end

          before do
            mock_nomis_with(:lookup_active_offender, offender)
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

        context 'with a null offender' do
          let(:offender) { Nomis::NullOffender.new }

          before do
            mock_nomis_with(:lookup_active_offender, offender)
          end

          it { expect(subject.errors_for(slot)).to be_empty }
        end
      end
    end

    context 'with slot availability' do
      context 'with NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED switched OFF', vcr: { cassette_name: 'lookup_active_offender', record: :new_episodes } do
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

      context 'with NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED switched ON', vcr: { cassette_name: 'lookup_active_offender', record: :new_episodes } do
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

            it { expect(subject.errors_for(slot)).to be_empty }
          end

          context 'with an error' do
            let(:message) { SlotAvailabilityValidation::SLOT_NOT_AVAILABLE }

            it { expect(subject.errors_for(slot)).to eq([message]) }
          end
        end
      end
    end

    context 'with prisoner restrictions', vcr: { cassette_name: 'book_visit_happy_path', record: :new_episodes } do
      before do
        switch_on(:nomis_staff_prisoner_check_enabled)
      end

      context 'when NOMIS_STAFF_OFFENDER_RESTRICTIONS_ENABLED' do
        context 'when it is disabled' do
          before do
            switch_off(:nomis_staff_offender_restrictions_enabled)
          end

          it { expect(subject.errors_for(slot)).to be_empty }
        end

        context 'when it is enabled' do
          before do
            switch_on(:nomis_staff_offender_restrictions_enabled)
            mock_nomis_with(:lookup_active_offender, offender)
          end

          context 'with a valid offender' do
            let(:prisoner_restrictions_list) do
              instance_double(PrisonerRestrictionList, on_slot: messages)
            end

            before do
              mock_service_with(PrisonerRestrictionList, prisoner_restrictions_list)
            end

            context 'with an error' do
              let(:messages) { [Nomis::Restriction::CLOSED_NAME] }

              it { expect(subject.errors_for(slot)).to eq(messages) }
            end

            context 'with no errors' do
              let(:messages) { [] }

              it { expect(subject.errors_for(slot)).to be_empty }
            end
          end

          context 'with a null offender' do
            let(:offender) { Nomis::NullOffender.new }

            it { expect(subject.errors_for(slot)).to be_empty }
          end
        end
      end
    end
  end

  describe '#slots_unavailable?' do
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

      it { is_expected.to be_slots_unavailable }
    end

    describe 'when the slots are unavailable' do
      before do
        allow(subject).
          to receive(:errors_for).
               with(anything).
               and_return([SlotAvailabilityValidation::SLOT_NOT_AVAILABLE])
      end

      it { is_expected.to be_slots_unavailable }
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

        allow(subject).to receive(:errors_for).with(slot1).and_return([])

        allow(subject).
          to receive(:errors_for).
               with(slot2).
               and_return([SlotAvailabilityValidation::SLOT_NOT_AVAILABLE])
      end

      it { is_expected.not_to be_slots_unavailable }
    end
  end

  describe '#no_allowance?' do
    let(:slot) { ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0) }

    before do
      is_expected.to receive(:errors_for).with(slot).and_return(errors)
    end

    context 'when there is no vo error' do
      let(:errors) { [Nomis::PrisonerDateAvailability::OUT_OF_VO] }

      it { is_expected.to be_no_allowance(slot) }
    end

    context "when there isn't a no vo error" do
      let(:errors) { [] }

      it { is_expected.not_to be_no_allowance(slot) }
    end
  end

  describe '#prisoner_banned?' do
    let(:slot) { ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0) }

    before do
      is_expected.to receive(:errors_for).with(slot).and_return(errors)
    end

    context 'when there is a prisoner banned error' do
      let(:errors) { [Nomis::PrisonerDateAvailability::BANNED] }

      it { is_expected.to be_prisoner_banned(slot) }
    end

    context "when there isn't prisoner banned error" do
      let(:errors) { [] }

      it { is_expected.not_to be_prisoner_banned(slot) }
    end
  end

  describe '#prisoner_out_of_prison?' do
    let(:slot) { ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0) }

    before do
      is_expected.to receive(:errors_for).with(slot).and_return(errors)
    end

    context 'when there is a prisoner out of prison error' do
      let(:errors) { [Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT] }

      it { is_expected.to be_prisoner_out_of_prison(slot) }
    end

    context "when there isn't prisoner out of prison error" do
      let(:errors) { [] }

      it { is_expected.not_to be_prisoner_out_of_prison(slot) }
    end
  end

  describe '#contact_list_unknown?' do
    let(:contact_list) do
      instance_double(PrisonerContactList)
    end

    context 'when the contact list returns an API error' do
      let(:contact_list_api_error) { true }

      before do
        mock_nomis_with(:lookup_active_offender, offender)
        expect(contact_list).to receive(:unknown_result?).and_return(contact_list_api_error)
        mock_service_with(PrisonerContactList, contact_list)
      end

      it { is_expected.to be_contact_list_unknown }
    end
  end

  describe '#prisoner_restrictions_unknown?' do
    context 'with NOMIS_STAFF_OFFENDER_RESTRICTION_ENABLED switched ON' do
      let(:restrictions_list) do
        instance_double(PrisonerRestrictionList)
      end

      let(:offender_restrictions_api_error) { false }

      before do
        switch_on(:nomis_staff_offender_restrictions_enabled)
        mock_nomis_with(:lookup_active_offender, offender)
        expect(restrictions_list).to receive(:unknown_result?).and_return(offender_restrictions_api_error)
        mock_service_with(PrisonerRestrictionList, restrictions_list)
      end

      it { is_expected.not_to be_prisoner_restrictions_unknown }

      context 'when the offender restrictions returns an API error' do
        let(:offender_restrictions_api_error) { true }

        it { is_expected.to be_prisoner_restrictions_unknown }
      end
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

  describe '#prisoner_restrictions' do
    context 'with the prison enabled' do
      before do
        switch_feature_flag_with(:staff_prisons_with_prisoner_restrictions_info, [visit.prison_name])
        switch_on(:nomis_staff_offender_restrictions_enabled)
        mock_nomis_with(:lookup_active_offender, offender)
        mock_service_with(PrisonerRestrictionList, prisoner_restrictions_list)
      end

      let(:active_restrictions) { [double(Nomis::Restriction)] }

      let(:prisoner_restrictions_list) do
        double(PrisonerRestrictionList, active: active_restrictions)
      end

      it { expect(subject.prisoner_restrictions).to eq(active_restrictions) }
    end

    context 'with the prisone not enabled' do
      before do
        switch_feature_flag_with(:staff_prisons_with_prisoner_restrictions_info, [])
      end

      it { expect(subject.prisoner_restrictions).to be_empty }
    end
  end

  describe '#offender' do
    before do
      mock_nomis_with(:lookup_active_offender, offender)
    end

    it { expect(subject.offender).to eq(offender) }
  end
end
