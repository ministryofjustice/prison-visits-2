require 'rails_helper'
require_relative 'shared_typed_list_examples'

RSpec.describe RestrictionList do
  include_examples '.new', Nomis::Restriction

  subject { described_class.new(arg) }

  describe '#to_a' do
    let(:arg) { [Nomis::Restriction.new] }

    it { expect(subject.to_a).to eq(arg) }
  end
end
