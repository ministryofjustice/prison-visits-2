require 'rails_helper'

RSpec.describe BookingResponse, type: :model do
  let(:visit) { create(:visit_with_two_visitors) }
  subject { described_class.new(visit: visit) }

  describe 'bookable?' do
    it 'is true if slot 0 is selected' do
      subject.selection = 'slot_0'
      expect(subject).to be_bookable
    end

    it 'is true if slot 1 is selected' do
      subject.selection = 'slot_1'
      expect(subject).to be_bookable
    end

    it 'is true if slot 2 is selected' do
      subject.selection = 'slot_2'
      expect(subject).to be_bookable
    end

    context 'there are multiple visitors' do
      context 'and one visitor is unlisted' do
        before do
          subject.selection = 'slot_0'
          subject.unlisted_visitor_ids = [visit.visitors.first.id]
        end

        it 'is bookable' do
          expect(subject).to be_bookable
        end
      end

      context 'and all visitors are unlisted' do
        before do
          subject.selection = 'slot_0'
          subject.unlisted_visitor_ids = visit.visitors.map(&:id)
        end

        it 'is not bookable' do
          expect(subject).not_to be_bookable
        end
      end

      context 'and one visitor is banned' do
        before do
          subject.selection = 'slot_0'
          subject.banned_visitor_ids = [visit.visitors.first.id]
        end

        it 'is bookable' do
          expect(subject).to be_bookable
        end
      end

      context 'and the allowed visitor is a child' do
        let(:visit) { create(:visit) }

        before do
          visit.prison.update!(adult_age: 16)
          visit.visitors.update_all(date_of_birth: 17.years.ago)
        end

        it 'is not bookable' do
          expect(subject).to_not be_bookable
        end
      end

      context 'and all visitors are banned' do
        before do
          subject.selection = 'slot_0'
          subject.banned_visitor_ids = visit.visitors.map(&:id)
        end

        it 'is not bookable' do
          expect(subject).not_to be_bookable
        end
      end
    end
  end

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
    before do
      subject.selection = 'slot_0'
      subject.reference_no = 12_345_678
    end

    describe 'visitor_not_on_list' do
      it 'is valid if visitors are selected' do
        subject.unlisted_visitor_ids = %w[ 42 ]
        expect(subject).to be_valid
      end
    end

    describe 'visitor_banned' do
      it 'is valid if it is visitor_banned and visitors are selected' do
        subject.banned_visitor_ids = %w[ 42 ]
        expect(subject).to be_valid
      end
    end

    it 'is invalid if the visit is not processable' do
      subject.visit.processing_state = 'booked'

      subject.selection = 'slot_unavailable'

      expect(subject).not_to be_valid
      expect(subject.errors).to have_key(:visit)
    end
  end

  describe 'selection=' do
    it 'is coerced to a string' do
      subject.selection = :slot_0
      expect(subject.selection).to eq('slot_0')
      expect(subject.selection).to be_a(String)
    end
  end
end
