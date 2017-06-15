require 'rails_helper'

RSpec.describe BookToNomisConfig do
  let(:checker) { instance_double(StaffNomisChecker) }
  let(:prison_name) { build_stubbed(:prison).name }
  let(:opted_in) { true }

  subject do
    described_class.new(checker, prison_name, opted_in)
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

  shared_context 'book to nomis enabled' do
    before do
      allow(Nomis::Feature).
        to receive(:book_to_nomis_enabled?).with(prison_name).and_return(true)
    end
  end

  shared_context 'prisoner exists' do
    before do
      allow(checker).to receive(:prisoner_existance_status).and_return(StaffNomisChecker::VALID)
    end
  end

  shared_context 'prisoner availability working' do
    before do
      allow(Nomis::Feature).to receive(:prisoner_availability_enabled?).and_return(true)
      allow(checker).to receive(:prisoner_availability_unknown?).and_return(false)
    end
  end

  shared_context 'slot availability working' do
    before do
      allow(Nomis::Feature).
        to receive(:slot_availability_enabled?).with(prison_name).and_return(true)
      allow(checker).to receive(:slot_availability_unknown?).and_return(false)
    end
  end

  shared_context 'contact list working' do
    before do
      allow(Nomis::Feature).
        to receive(:contact_list_enabled?).with(prison_name).and_return(true)
      allow(checker).to receive(:contact_list_unknown?).and_return(false)
    end
  end

  describe '#book_to_nomis_possible?' do
    context 'when all the checks return true' do
      include_context 'book to nomis enabled'
      include_context 'prisoner exists'
      include_context 'prisoner availability working'
      include_context 'slot availability working'
      include_context 'contact list working'

      it { is_expected.to be_possible_to_book }
    end

    context 'when the prisoner does not exist' do
      include_context 'book to nomis enabled'
      include_context 'prisoner availability working'
      include_context 'slot availability working'
      include_context 'contact list working'

      before do
        expect(checker).
          to receive(:prisoner_existance_status).
          and_return(StaffNomisChecker::UNKNOWN)
      end

      it { is_expected.not_to be_possible_to_book }
    end

    context 'when all the prisoner availability is not working' do
      include_context 'book to nomis enabled'
      include_context 'prisoner exists'
      include_context 'slot availability working'
      include_context 'contact list working'

      context 'due to the feature being disabled' do
        before do
          expect(Nomis::Feature).to receive(:prisoner_availability_enabled?).and_return(false)
        end

        it { is_expected.not_to be_possible_to_book }
      end

      context 'due to the api call response being unknown' do
        before do
          allow(Nomis::Feature).to receive(:prisoner_availability_enabled?).and_return(true)
          expect(checker).to receive(:prisoner_availability_unknown?).and_return(true)
        end

        it { is_expected.not_to be_possible_to_book }
      end
    end

    context 'when all the slot availability is not working' do
      include_context 'book to nomis enabled'
      include_context 'prisoner exists'
      include_context 'prisoner availability working'
      include_context 'contact list working'

      context 'due to the feature being disabled' do
        before do
          expect(Nomis::Feature).
            to receive(:slot_availability_enabled?).with(prison_name).and_return(false)
        end

        it { is_expected.not_to be_possible_to_book }
      end

      context 'due to the api call response being unknown' do
        before do
          allow(Nomis::Feature).
            to receive(:slot_availability_enabled?).with(prison_name).and_return(true)

          expect(checker).to receive(:slot_availability_unknown?).and_return(true)
        end

        it { is_expected.not_to be_possible_to_book }
      end
    end

    context 'when the contact list is not working' do
      include_context 'book to nomis enabled'
      include_context 'prisoner exists'
      include_context 'prisoner availability working'
      include_context 'slot availability working'

      context 'due to the feature being disabled' do
        before do
          expect(Nomis::Feature).
            to receive(:contact_list_enabled?).with(prison_name).and_return(false)
        end

        it { is_expected.not_to be_possible_to_book }
      end

      context 'due to the api call response being unknown' do
        before do
          allow(Nomis::Feature).
            to receive(:contact_list_enabled?).with(prison_name).and_return(true)

          expect(checker).to receive(:contact_list_unknown?).and_return(true)
        end

        it { is_expected.not_to be_possible_to_book }
      end
    end
  end
end
