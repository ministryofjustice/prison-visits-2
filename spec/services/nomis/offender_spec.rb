require "rails_helper"

RSpec.describe Nomis::Offender, type: :model do
  it { is_expected.to validate_presence_of :id }
  it { is_expected.to validate_presence_of :noms_id }
end
