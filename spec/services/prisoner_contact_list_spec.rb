require 'rails_helper'

RSpec.describe PrisonerContactList, type: :model do
  let(:offender) { Nomis::Offender.new(id: 1) }
  subject(:instance) { described_class.new(offender) }

  context '#unknown_result?' do
    subject { instance.unknown_result? }

    context "when it's a null offender" do
      let(:offender) { Nomis::NullOffender.new }

      it { is_expected.to eq(true) }
    end

    context "when the api returns an error" do
      before do
        expect_any_instance_of(Nomis::Api).
          to receive(:fetch_contact_list).
          with(offender_id: offender.id).
          and_raise(Nomis::APIError)
      end

      it { is_expected.to eq(true) }
    end

    context "when the api returns no error" do
      let(:contact_list) { Nomis::ContactList.new }
      before do
        expect_any_instance_of(Nomis::Api).
          to receive(:fetch_contact_list).
          with(offender_id: offender.id).
          and_return(contact_list)
      end

      it { is_expected.to eq(false) }
    end
  end
end
