require "rails_helper"

RSpec.describe RestrictionTypeType do
  subject { described_class.new }

  let(:value) do
    { desc: 'type description', code: 'type code' }
  end

  let(:casted_value) { subject.cast(value) }

  it { expect(casted_value.desc).to eq(value[:desc]) }
  it { expect(casted_value.code).to eq(value[:code]) }
end
