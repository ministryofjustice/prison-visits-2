require 'rails_helper'
require_relative 'shared_type_examples'

RSpec.describe ConcreteSlotListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { ['2016-01-01T09:00/10:00', '2016-01-01T10:00/11:00'] }

    include_examples 'enumerable type', ConcreteSlotList
  end
end
