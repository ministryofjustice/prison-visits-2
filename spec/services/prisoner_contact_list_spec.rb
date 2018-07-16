require 'rails_helper'

RSpec.describe PrisonerContactList, type: :model do
  let(:prisoner) do
    Nomis::Prisoner.new(id: 1, noms_id: 'prisoner_number')
  end

  subject { described_class.new(prisoner) }

  context 'with #unknown_result?' do
    context "when it's a null prisoner" do
      let(:prisoner) { Nomis::NullPrisoner.new }

      it { is_expected.to be_unknown_result }
    end

    context "when the api returns an error" do
      before do
        simulate_api_error_for(:fetch_contact_list)
      end

      it { is_expected.to be_unknown_result }
    end

    context "when the api returns no error" do
      let(:contact_list) { Nomis::ContactList.new }

      before do
        mock_nomis_with(:fetch_contact_list, contact_list)
      end

      it { is_expected.not_to be_unknown_result }
    end
  end

  describe '#approved' do
    context 'when the api returns no error' do
      let(:contact_list) { Nomis::ContactList.new }

      before do
        mock_nomis_with(:fetch_contact_list, contact_list)
      end

      it 'returns the contact list' do
        expect(subject.approved).to eq(contact_list.approved)
      end
    end

    context 'when the api returns no error' do
      before do
        simulate_api_error_for(:fetch_contact_list)
      end

      it 'returns an empty contact list' do
        expect(subject.approved).to eq([])
      end
    end
  end
end
