require 'rails_helper'

RSpec.describe BookingResponse, type: :model do
  describe 'slot_selected?' do
    it 'is true if slot 0 is selected' do
      subject.selection = 'slot_0'
      expect(subject).to be_slot_selected
    end

    it 'is true if slot 1 is selected' do
      subject.selection = 'slot_1'
      expect(subject).to be_slot_selected
    end

    it 'is true if slot 2 is selected' do
      subject.selection = 'slot_2'
      expect(subject).to be_slot_selected
    end

    it 'is false if any other option is selected' do
      subject.selection = 'slot_unavailable'
      expect(subject).not_to be_slot_selected
    end
  end

  context 'validations' do
    describe 'selection' do
      it 'is valid if it is visitor_not_on_list and visitors are selected' do
        subject.selection = 'visitor_not_on_list'
        subject.unlisted_visitor_ids = %w[ 42 ]
        expect(subject).to be_valid
      end

      it 'is invalid if it is visitor_not_on_list but no visitors are selected' do
        subject.selection = 'visitor_not_on_list'
        expect(subject).not_to be_valid
        expect(subject.errors).to have_key(:selection)
      end

      it 'is valid if it is visitor_banned and visitors are selected' do
        subject.selection = 'visitor_banned'
        subject.banned_visitor_ids = %w[ 42 ]
        expect(subject).to be_valid
      end

      it 'is invalid if it is visitor_banned but no visitors are selected' do
        subject.selection = 'visitor_banned'
        expect(subject).not_to be_valid
        expect(subject.errors).to have_key(:selection)
      end
    end
  end
end
