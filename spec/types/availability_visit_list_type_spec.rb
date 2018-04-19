require 'rails_helper'
require_relative 'shared_type_examples'

RSpec.describe AvailabilityVisitListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { [{}, {}] }

    include_examples 'type', Nomis::AvailabilityVisit
  end
end
