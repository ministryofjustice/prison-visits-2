require 'rails_helper'

RSpec.describe VisitorDecorator do
  let(:visitor) { Visitor.new }
  subject(:instance) { described_class.new(visitor) }
end
