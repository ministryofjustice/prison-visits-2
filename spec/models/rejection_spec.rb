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

  describe 'privileged_allowance_available?' do
    it 'is true if there is a privileged_allowance_expires_on date' do
      subject.privileged_allowance_expires_on = Time.zone.today + 1
      expect(subject).to be_privileged_allowance_available
    end

    it 'is false if these is no privileged_allowance_expires_on date' do
      subject.privileged_allowance_expires_on = ''
      expect(subject).not_to be_privileged_allowance_available
    end
  end

  describe 'allowance_will_renew?' do
    it 'is true if there is an allowance_renews_on date' do
      subject.allowance_renews_on = Time.zone.today + 1
      expect(subject).to be_allowance_will_renew
    end

    it 'is false if these is no allowance_renews_on date' do
      subject.allowance_renews_on = ''
      expect(subject).not_to be_allowance_will_renew
    end
  end
end
