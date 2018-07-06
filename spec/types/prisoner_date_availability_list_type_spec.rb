require 'rails_helper'
require_relative 'shared_type_examples'

RSpec.describe PrisonerDateAvailabilityListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { [{}, {}] }

    include_examples 'type', Nomis::Offender::DateAvailability
  end
end
