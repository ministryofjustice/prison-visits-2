require 'rails_helper'
require_relative 'shared_type_examples'

RSpec.describe RestrictionListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { [{}, {}] }

    include_examples 'enumerable type', RestrictionList
  end
end
