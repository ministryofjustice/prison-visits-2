require 'rails_helper'

RSpec.describe Nomis::Contact do
  let(:restrictions) { [] }

  subject do
    described_class.new(
      id: 12_588,
      given_name: 'BILLY',
      surname: 'JONES',
      date_of_birth: '1970-01-01',
      gender: { code: "M", desc: "Male" },
      active: true,
      approved_visitor: true,
      relationship_type: { code: "FRI", desc: "Friend" },
      contact_type: {
        code: "S",
        desc: "Social/ Family"
      },
      restrictions:
    )
  end

  it { expect(subject.gender).to            be_instance_of(Nomis::Contact::Gender) }
  it { expect(subject.relationship_type).to be_instance_of(Nomis::Contact::Relationship) }
  it { expect(subject.contact_type).to      be_instance_of(Nomis::Contact::ContactType) }

  describe '#full_name' do
    it 'concatenate given_name and surname' do
      expect(subject.full_name).to eq('billy jones')
    end
  end

  describe '#banned?' do
    context 'with no restrictions' do
      let(:restrictions) { [] }

      it { is_expected.not_to be_banned }
    end

    context 'with other type of restrictions' do
      let(:restrictions) do
        [
          Nomis::Restriction.new(
            effective_date: '2017-03-02',
            expiry_date: '2017-04-02',
            type: { 'code' => "CLOSED", 'desc' => "Closed" })
        ]
      end

      it { is_expected.not_to be_banned }
    end

    context 'with a banned restriction' do
      let(:restrictions) do
        [
          Nomis::Restriction.new(
            effective_date: '2017-03-02',
            expiry_date: '2017-04-02',
            type: { 'code' => "BAN", 'desc' => "Banned" })
        ]
      end

      it { is_expected.to be_banned }
    end
  end

  context "when #banned_until" do
    context 'with a banned restriction with an expiry date' do
      let(:expiry_date) { Date.parse('2017-04-02') }
      let(:restrictions) do
        [
          Nomis::Restriction.new(
            effective_date: '2017-03-02',
            expiry_date:,
            type: { 'code' => "BAN", 'desc' => "Banned" })
        ]
      end

      it { expect(subject.banned_until).to eq(expiry_date) }
    end

    context 'with a banned restriction with no expiry' do
      let(:restrictions) do
        [
          Nomis::Restriction.new(
            effective_date: '2017-03-02',
            expiry_date: nil,
            type: { 'code' => "BAN", 'desc' => "Banned" })
        ]
      end

      it { expect(subject.banned_until).to be nil }
    end

    context 'with no banned restriction' do
      let(:restrictions) do
        [
          Nomis::Restriction.new(
            effective_date: '2017-03-02',
            expiry_date: '2017-04-02',
            type: { 'code' => "CLOSED", 'desc' => "Closed" })
        ]
      end

      it { expect(subject.banned_until).to be nil }
    end
  end

  describe '#<=>' do
    it 'returns 1 when first contact is greater than the second' do
      first_contact = described_class.new(surname: "Jones", given_name: "Grace")
      second_contact = described_class.new(surname: "Jones", given_name: "Billy")
      expect(first_contact <=> second_contact).to eq(1)
    end

    it 'returns -1 when the first contact is lesser than the second' do
      first_contact = described_class.new(surname: "Franklin", given_name: "Adam")
      second_contact = described_class.new(surname: "Poppins", given_name: "Jeff")
      expect(first_contact <=> second_contact).to eq(-1)
    end

    it 'returns 0 when the first contact matches the second' do
      first_contact = described_class.new(surname: "Smith", given_name: "John")
      second_contact = described_class.new(surname: "Smith", given_name: "John")
      expect(first_contact <=> second_contact).to eq(0)
    end
  end
end
