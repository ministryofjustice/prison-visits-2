require 'rails_helper'

RSpec.describe Cancellation, model: true do
  describe 'validation' do
    it 'enforces no more than one per visit' do
      cancellation = FactoryGirl.create(:cancellation)
      expect {
        FactoryGirl.create(:cancellation, visit: cancellation.visit)
      }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect {
        FactoryGirl.create(:cancellation, visit_id: SecureRandom.uuid)
      }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end

    it 'checks the reason code is allowed' do
      cancellation = FactoryGirl.build_stubbed(:cancellation)
      cancellation.reason = 'random'
      expect(cancellation).to be_invalid
      expect(cancellation.errors[:reason]).to be_present
    end
  end
end
