require 'rails_helper'
require_relative 'shared_typed_list_examples'

RSpec.describe DateList do
  include_examples '.new', Date
end
