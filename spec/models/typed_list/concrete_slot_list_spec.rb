require 'rails_helper'
require_relative 'shared_typed_list_examples'

RSpec.describe ConcreteSlotList do
  include_examples '.new', ConcreteSlot
end
