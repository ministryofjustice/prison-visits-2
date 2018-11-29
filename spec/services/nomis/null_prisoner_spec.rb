require "rails_helper"

RSpec.describe Nomis::NullPrisoner do
  it { expect(subject.iep_level).to eq(nil) }
  it { expect(subject.imprisonment_status).to eq(nil) }
end
