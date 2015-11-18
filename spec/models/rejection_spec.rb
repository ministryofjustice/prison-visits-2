require 'rails_helper'

RSpec.describe Rejection, model: true do
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
