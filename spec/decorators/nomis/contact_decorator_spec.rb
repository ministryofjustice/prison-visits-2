require "rails_helper"

RSpec.describe Nomis::ContactDecorator do
  let(:contact) { build(:contact) }

  subject { described_class.decorate(contact)  }

  describe '#full_name_and_dob' do
    let(:full_name) { "#{contact.given_name} #{contact.surname}" }

    context 'with a dob' do
      it { expect(subject.full_name_and_dob).to eq("#{full_name} - #{contact.date_of_birth.to_fs(:short_nomis)}") }
    end

    context 'with no dob' do
      before do
        contact.date_of_birth = nil
      end

      it { expect(subject.full_name_and_dob).to eq(full_name) }
    end
  end

  describe '#to_data_attributes' do
    it { expect(subject.to_data_attributes).to include(uid: contact.id, banned: contact.banned?) }
  end
end
