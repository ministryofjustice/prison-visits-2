require 'rails_helper'
require_relative 'shared_typed_list_examples'

RSpec.describe ApiSlotList do
  include_examples '.new', Nomis::ApiSlot
end
