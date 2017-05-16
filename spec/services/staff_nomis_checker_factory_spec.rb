require 'rails_helper'

RSpec.describe StaffNomisCheckerFactory do
  subject { described_class.for(visit) }

  describe 'for a requested visit' do
    let(:visit) { build_stubbed(:visit, :requested) }

    it { is_expected.to be_instance_of(StaffNomisChecker) }
  end

  describe 'for a non requested visit' do
    let(:visit) { build_stubbed(:visit, :booked) }

    it { is_expected.to be_instance_of(NullStaffNomisChecker) }
  end
end
