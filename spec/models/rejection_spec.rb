require 'rails_helper'

RSpec.describe Rejection, model: true do
  describe 'validation' do
    it 'enforces no more than one per visit' do
      visit = create(:visit)
      create(:rejection, visit: visit)
      expect {
        create(:rejection, visit: visit)
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect {
        create(:rejection, visit_id: SecureRandom.uuid)
      }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end
  end

  describe 'pvo_possible?' do
    it 'is true if there is a pvo_expires_on date' do
      subject.pvo_expires_on = Time.zone.today + 1
      expect(subject).to be_pvo_possible
    end

    it 'is false if these is no pvo_expires_on date' do
      subject.pvo_expires_on = ''
      expect(subject).not_to be_pvo_possible
    end
  end

  describe 'vo_will_be_renewed?' do
    it 'is true if there is a vo_renewed_on date' do
      subject.vo_renewed_on = Time.zone.today + 1
      expect(subject).to be_vo_will_be_renewed
    end

    it 'is false if these is no vo_renewed_on date' do
      subject.vo_renewed_on = ''
      expect(subject).not_to be_vo_will_be_renewed
    end
  end
end
