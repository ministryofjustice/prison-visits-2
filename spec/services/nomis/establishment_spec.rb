require "rails_helper"

RSpec.describe Nomis::Establishment, type: :model do
  subject { build(:establishment) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of :code }
  end
end
