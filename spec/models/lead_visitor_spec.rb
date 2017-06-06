require "rails_helper"

RSpec.describe LeadVisitor do
  describe 'association' do
    it { is_expected.to belong_to(:visit) }
  end
end
