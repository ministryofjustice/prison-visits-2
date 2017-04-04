require 'spec_helper'

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
    subject { instance.approved }

    it 'returns approved and active contacts' do
      expect(subject.map(&:id)).to eq([approved_active.id])
    end
  end
end
