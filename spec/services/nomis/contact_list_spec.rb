require 'rails_helper'

RSpec.describe Nomis::ContactList do
  let(:approved_active) do
    Nomis::Contact.new(id: 1, active: true, approved_visitor: true)
  end

  let(:disapproved_active) do
    Nomis::Contact.new(id: 2, active: true, approved_visitor: false)
  end

  let(:approved_inactive) do
    Nomis::Contact.new(id: 3, active: false, approved_visitor: true)
  end

  let(:disapproved_inactive) do
    Nomis::Contact.new(id: 4, active: false, approved_visitor: false)
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
end
