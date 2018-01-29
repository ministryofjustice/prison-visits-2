require 'rails_helper'

RSpec.describe Nomis::ContactList do
  let(:approved_active) do
    Nomis::Contact.new(id: 1, active: true, surname: "Janklin", given_name: "Dave", approved_visitor: true)
  end

  let(:disapproved_active) do
    Nomis::Contact.new(id: 2, active: true, surname: "Buster", given_name: "Kristen", approved_visitor: false)
  end

  let(:approved_inactive) do
    Nomis::Contact.new(id: 3, active: false, surname: "Zoomer", given_name: "Pete", approved_visitor: true)
  end

  let(:disapproved_inactive) do
    Nomis::Contact.new(id: 4, active: false, surname: "Buster", given_name: "Kate", approved_visitor: false)
  end

  subject(:instance) do
    described_class.new(contacts: [
      approved_active,
      disapproved_active,
      approved_inactive,
      disapproved_inactive
    ])
  end

  describe '#approved' do
    it 'returns only approved contacts regardless of active or inactive' do
      expect(subject.approved.size).to eq(2)
      expect(subject.map(&:id)).to include(approved_active.id)
      expect(subject.map(&:id)).to include(approved_inactive.id)
    end
  end

  it 'returns an alphabetically ordered list of contacts, by surname and then first name' do
    contacts = subject.map{ |k, _| [k.surname, k.given_name] }
    expect(contacts).to eq [%w[Buster Kate], %w[Buster Kristen], %w[Janklin Dave], %w[Zoomer Pete]]
  end

  describe '#api_call_successful?' do
    it { expect(subject).to be_api_call_successful }
  end
end
