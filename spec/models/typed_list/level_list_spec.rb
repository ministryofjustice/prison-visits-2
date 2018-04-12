require "rails_helper"
require_relative 'shared_typed_list_examples'

RSpec.describe LevelList do
  include_examples '.new', Nomis::HousingLocation::Level

  subject { described_class.new(arg) }

  describe '#to_a' do
    let(:arg) { [Nomis::HousingLocation::Level.new] }

    it { expect(subject.to_a).to eq(arg) }
  end
end
