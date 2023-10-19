require "rails_helper"
require_relative 'shared_type_examples'

RSpec.describe LevelListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { [{}, {}] }

    it do
      expect(subject.cast(value))
        .to all(be_instance_of(Nomis::HousingLocation::Level))
    end
  end
end
