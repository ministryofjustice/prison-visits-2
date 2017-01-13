require 'rails_helper'

RSpec.describe PercentilesByCalendarDate, type: :model do
  subject do
    described_class.new(
      date: Time.zone.today,
      percentiles: [1.day.to_i, 2.days.to_i]
    )
  end

  it_behaves_like 'percentile serialisable'
  it { is_expected.to be_readonly }
end
