require 'rails_helper'

RSpec.describe VisitOrder, type: :model do
  it { is_expected.to belong_to(:visit) }
end
