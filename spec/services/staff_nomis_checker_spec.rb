require 'rails_helper'

RSpec.describe StaffNomisChecker do
  subject { described_class.new(visit) }

  # Enabled for slot availability
  let(:prison)   { build_stubbed(:prison, name: 'Pentonville') }
  let(:pvb_prisoner) { build_stubbed(:prisoner) }
  let(:visit)    { build_stubbed(:visit, prisoner: pvb_prisoner, prison: prison) }
  let(:nomis_prisoner) { Nomis::Prisoner.new(id: 'some_noms_id', noms_id: pvb_prisoner.number) }

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

    describe '#errors_for' do
      it { expect(subject.errors_for(visit.slots.first)).to be_empty }
    end

    describe '#prisoner' do
      it { expect(subject.prisoner).to be_instance_of(Nomis::NullPrisoner) }
    end
  end

  describe '#prisoner_availability_unknown?' do
    let(:prisoner_availability_validation) do
      instance_double(PrisonerAvailabilityValidation,
                      valid?: false, unknown_result?: unknown_result)
    end

    before do
      mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
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

    context 'when the api is disabled' do
      before do
        switch_off_api
      end

      it { expect(subject.errors_for(slot)).to be_empty }
    end

    context 'when the api is enabled' do
      let(:slot_date) { Time.zone.today + 10.days }
      let(:api) { 'https://prison-api-dev.prison.service.justice.gov.uk/api/v1' }

      before do
        stub_auth_token
        stub_request(:get, "#{api}/prison/#{prison.nomis_id}/slots?end_date=#{slot_date}&start_date=#{slot_date}").
          to_return(body: { slots: ["time": "#{slot_date}T14:00/16:10"] }.to_json)
      end

      context 'with a valid prisoner' do
        let(:prisoner_availability_validator) do
          instance_double(PrisonerAvailabilityValidation, valid?: false, slot_errors: messages)
        end

        before do
          mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
          mock_service_with(PrisonerAvailabilityValidation, prisoner_availability_validator)
        end

        context 'with an error' do
          let(:messages) { [Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT] }

          it { expect(subject.errors_for(slot)).to eq(messages) }
        end

        context 'with no errors' do
          let(:messages) { [] }

          it { expect(subject.errors_for(slot)).to eq([]) }
        end
      end

      context 'with a null prisoner' do
        let(:nomis_prisoner) { Nomis::NullPrisoner.new }

        before do
          mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
        end

        it { expect(subject.errors_for(slot)).to be_empty }
      end
    end

    context 'with slot availability' do
      context 'with NOMIS_STAFF_SLOT_AVAILABILITY_ENABLED switched OFF' do
        let(:prisoner_availability_validator) do
          instance_double(PrisonerAvailabilityValidation, valid?: false, slot_errors: [])
        end

        before do
          mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
          mock_service_with(PrisonerAvailabilityValidation, prisoner_availability_validator)
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
          mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
        end

        describe "and STAFF_PRISONS_WITH_SLOT_AVAILABILITY switched ON for the visit's prison" do
          let(:message)  { nil }
          let(:slot_availability_validation) do
            instance_double(SlotAvailabilityValidation, valid?: false, slot_error: message)
          end

          let(:prisoner_availability_validator) do
            instance_double(PrisonerAvailabilityValidation, valid?: false, slot_errors: [])
          end

          before do
            switch_feature_flag_with(:staff_prisons_with_slot_availability, %w[Pentonville Cardiff])
            mock_service_with(SlotAvailabilityValidation, slot_availability_validation)
            mock_service_with(PrisonerAvailabilityValidation, prisoner_availability_validator)
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
      expect(subject).to receive(:errors_for).with(slot).and_return(errors)
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

  describe '#prisoner_out_of_prison?' do
    let(:slot) { ConcreteSlot.new(2015, 11, 6, 18, 0, 19, 0) }

    before do
      expect(subject).to receive(:errors_for).with(slot).and_return(errors)
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
        mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
        expect(contact_list).to receive(:unknown_result?).and_return(contact_list_api_error)
        mock_service_with(PrisonerContactList, contact_list)
      end

      it { is_expected.to be_contact_list_unknown }
    end
  end

  describe '#approved_contacts' do
    let(:approved_contacts) { double }
    let(:contact_list) do
      instance_double(PrisonerContactList, approved: approved_contacts)
    end

    before do
      mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
      mock_service_with(PrisonerContactList, contact_list)
    end

    it 'returns the prisoner approved contacts' do
      expect(subject.approved_contacts).to eq(approved_contacts)
    end
  end

  describe '#prisoner' do
    before do
      mock_nomis_with(:lookup_active_prisoner, nomis_prisoner)
    end

    it { expect(subject.prisoner).to eq(nomis_prisoner) }
  end
end
