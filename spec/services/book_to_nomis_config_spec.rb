require 'rails_helper'

RSpec.describe BookToNomisConfig do
  let(:checker)                    { instance_double(StaffNomisChecker) }
  let(:prisoner_details_presenter) { instance_double(PrisonerDetailsPresenter) }
  let(:prison_name)                { build_stubbed(:prison).name }
  let(:opted_in)                   { true }
  let(:already_booked_in_nomis)    { true }

  subject do
    described_class.new(
      checker,
      prison_name,
      opted_in,
      already_booked_in_nomis,
      prisoner_details_presenter
    )
  end

  describe '#opted_in?' do
    describe 'when the book to nomis is not possible' do
      before do
        expect(subject).to receive(:possible_to_book?).and_return(false)
      end

      it { is_expected.not_to be_opted_in }
    end

    describe 'when the book to nomis is possible' do
      before do
        expect(subject).to receive(:possible_to_book?).and_return(true)
      end

      describe "when the visit hasn't set the book to nomis opt out flag" do
        let(:opted_in) { nil }

        it { is_expected.to be_opted_in }
      end

      describe "when the visit has book to nomis opt out flag set to false" do
        let(:opted_in) { 'false' }

        it { is_expected.not_to be_opted_in }
      end

      describe "when the visit has book to nomis opt out flag set to true" do
        let(:opted_in) { 'true' }

        it { is_expected.to be_opted_in }
      end
    end
  end

  shared_context 'with book to nomis enabled' do
    before do
      allow(Nomis::Feature).
        to receive(:book_to_nomis_enabled?).with(prison_name).and_return(true)
    end
  end

  shared_context 'with prisoner exists' do
    before do
      allow(prisoner_details_presenter).
        to receive(:prisoner_existance_status).and_return(PrisonerDetailsPresenter::VALID)
    end
  end

  shared_context 'with prisoner availability working' do
    before do
      allow(checker).to receive(:prisoner_availability_unknown?).and_return(false)
    end
  end

  shared_context 'with slot availability working' do
    before do
      allow(Nomis::Feature).
        to receive(:slot_availability_enabled?).with(prison_name).and_return(true)
      allow(checker).to receive(:slot_availability_unknown?).and_return(false)
    end
  end

  shared_context 'with contact list working' do
    before do
      allow(checker).to receive(:contact_list_unknown?).and_return(false)
    end
  end

  shared_context 'with offender restrictions working' do
    before do
      allow(Nomis::Feature).
        to receive(:restrictions_enabled?).and_return(true)
      allow(checker).to receive(:prisoner_restrictions_unknown?).and_return(false)
    end
  end

  shared_context 'when not booked in NOMIS' do
    let(:already_booked_in_nomis) { false }
  end

  describe '#book_to_nomis_possible?' do
    context 'when all the checks return true' do
      include_context 'when not booked in NOMIS'
      include_context 'with book to nomis enabled'
      include_context 'with prisoner exists'
      include_context 'with prisoner availability working'
      include_context 'with slot availability working'
      include_context 'with contact list working'
      include_context 'with offender restrictions working'

      it { is_expected.to be_possible_to_book }
    end

    context 'when the prisoner does not exist' do
      include_context 'when not booked in NOMIS'
      include_context 'with book to nomis enabled'
      include_context 'with prisoner availability working'
      include_context 'with slot availability working'
      include_context 'with contact list working'
      include_context 'with offender restrictions working'

      before do
        expect(prisoner_details_presenter).
          to receive(:prisoner_existance_status).
          and_return(PrisonerValidation::UNKNOWN)
      end

      it { is_expected.not_to be_possible_to_book }
    end

    context 'with the api call response being unknown for the prisoner availability' do
      include_context 'when not booked in NOMIS'
      include_context 'with book to nomis enabled'
      include_context 'with prisoner exists'
      include_context 'with slot availability working'
      include_context 'with contact list working'
      include_context 'with offender restrictions working'

      before do
        expect(checker).to receive(:prisoner_availability_unknown?).and_return(true)
      end

      it { is_expected.not_to be_possible_to_book }
    end

    context 'when all the slot availability is not working' do
      include_context 'when not booked in NOMIS'
      include_context 'with book to nomis enabled'
      include_context 'with prisoner exists'
      include_context 'with prisoner availability working'
      include_context 'with contact list working'
      include_context 'with offender restrictions working'

      context 'with the feature being disabled' do
        before do
          expect(Nomis::Feature).
            to receive(:slot_availability_enabled?).with(prison_name).and_return(false)
        end

        it { is_expected.not_to be_possible_to_book }
      end

      context 'with the api call response being unknown' do
        before do
          allow(Nomis::Feature).
            to receive(:slot_availability_enabled?).with(prison_name).and_return(true)

          expect(checker).to receive(:slot_availability_unknown?).and_return(true)
        end

        it { is_expected.not_to be_possible_to_book }
      end
    end

    context 'when the contact list is not working' do
      include_context 'when not booked in NOMIS'
      include_context 'with book to nomis enabled'
      include_context 'with prisoner exists'
      include_context 'with prisoner availability working'
      include_context 'with slot availability working'
      include_context 'with offender restrictions working'

      context 'with the api call response being unknown' do
        before do
          expect(checker).to receive(:contact_list_unknown?).and_return(true)
        end

        it { is_expected.not_to be_possible_to_book }
      end
    end

    context 'when the offender restrictions list is not working' do
      include_context 'when not booked in NOMIS'
      include_context 'with book to nomis enabled'
      include_context 'with prisoner exists'
      include_context 'with prisoner availability working'
      include_context 'with slot availability working'
      include_context 'with contact list working'

      context 'with the feature being disabled' do
        before do
          expect(Nomis::Feature).
            to receive(:restrictions_enabled?).and_return(false)
        end

        it { is_expected.not_to be_possible_to_book }
      end

      context 'with the api call response being unknown' do
        before do
          allow(Nomis::Feature).
            to receive(:restrictions_enabled?).and_return(true)

          expect(checker).to receive(:prisoner_restrictions_unknown?).and_return(true)
        end

        it { is_expected.not_to be_possible_to_book }
      end
    end

    context 'when the visit is already in NOMIS' do
      include_context 'with book to nomis enabled'
      include_context 'with prisoner exists'
      include_context 'with prisoner availability working'
      include_context 'with slot availability working'
      include_context 'with contact list working'

      let(:already_booked_in_nomis) { true }

      it { is_expected.not_to be_possible_to_book }
    end
  end
end
