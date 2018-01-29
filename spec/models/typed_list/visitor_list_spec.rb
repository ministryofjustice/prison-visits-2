require 'rails_helper'
require_relative 'shared_typed_list_examples'

RSpec.describe VisitorList do
  include_examples '.new', Visitor

  subject { described_class.new(arg) }

  describe '#to_a' do
    let(:arg) { [Visitor.new] }

    it { expect(subject.to_a).to eq(arg) }
  end
end
