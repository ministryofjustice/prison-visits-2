require 'rails_helper'
require_relative 'shared_type_examples'

RSpec.describe ApiSlotListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { [{}, {}] }

    include_examples 'enumerable type', ApiSlotList
  end
end
