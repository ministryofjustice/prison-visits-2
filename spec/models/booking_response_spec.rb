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
end
