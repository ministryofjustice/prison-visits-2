require "rails_helper"

RSpec.describe Nomis::NullPrisoner do
  it { expect(subject.iep_level).to be_nil }
  it { expect(subject.imprisonment_status).to be_nil }
end
