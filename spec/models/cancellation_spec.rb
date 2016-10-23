require 'rails_helper'

RSpec.describe Cancellation, model: true do
  let(:visit) { create(:visit) }
  subject { build(:cancellation, visit: visit) }

  describe 'validation' do
    context 'with a booked vbisit' do
      let(:visit) { create(:booked_visit) }
      it 'can not cancel for a booked visit' do
        is_expected.to_not be_valid
        expect(subject.errors.full_messages).to eq(["Can't cancel an already booked date"])
      end
    end
    it 'enforces no more than one per visit' do
      subject.save!
      expect {
        create(:cancellation, visit: subject.visit)
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect {
        create(:cancellation, visit_id: create(:user).id)
      }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end

    it 'checks the reason code is allowed' do
      subject.reason = 'random'
      expect(subject).to be_invalid
      expect(subject.errors[:reason]).to be_present
    end
  end
end
