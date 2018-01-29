require 'rails_helper'
require_relative 'shared_type_examples'

RSpec.describe DateListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { ['2017-01-01', '2017-01-02'] }

    include_examples 'enumerable type', DateList
  end
end
