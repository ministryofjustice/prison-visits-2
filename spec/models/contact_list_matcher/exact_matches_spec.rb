require "rails_helper"

RSpec.describe ContactListMatcher::ExactMatches do
  describe '#contact_id' do
    let(:contact_id) { 12 }

    context 'with a contact' do
      before do
        subject.add(1, double('contact', id: contact_id))
      end

      it 'returns its id' do
        expect(subject.contact_id).to eq(contact_id)
      end
    end

    context 'with no contacts' do
      it 'returns nil' do
        expect(subject.contact_id).to be nil
      end
    end
  end
end
