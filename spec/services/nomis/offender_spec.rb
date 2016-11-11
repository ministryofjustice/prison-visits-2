require "rails_helper"

RSpec.describe Nomis::Offender, type: :model do
  it { is_expected.to validate_presence_of :id  }
end
