require 'rails_helper'
require_relative 'shared_typed_list_examples'

RSpec.describe PrisonerDateAvailabilityList do
  include_examples '.new', Nomis::PrisonerDateAvailability
end
