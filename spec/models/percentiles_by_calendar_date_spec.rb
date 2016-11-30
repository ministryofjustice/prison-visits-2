require 'rails_helper'

RSpec.describe PercentilesByCalendarDate, type: :model do
  subject do
    described_class.new(
      date: Date.today,
      percentiles: [1.day.to_i, 2.day.to_i]
    )
  end

  it_behaves_like 'percentile serialisable'
  it { is_expected.to be_readonly }
end
