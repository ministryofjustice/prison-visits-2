require 'rails_helper'
require_relative 'shared_typed_list_examples'

RSpec.describe AvailabilityVisitList do
  include_examples '.new', Nomis::AvailabilityVisit
end
