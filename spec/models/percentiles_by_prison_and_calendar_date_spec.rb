require 'rails_helper'

RSpec.describe PercentilesByPrisonAndCalendarDate, type: :model do
  let(:prison)                          { create :prison }
  let(:processed_within_a_day_visits)   do
    create_list(
      :visit, 4,
      prison:,
      created_at: Time.zone.today.beginning_of_day
    )
  end
  let(:processed_within_two_days_visit) do
    create(
      :visit,
      prison:,
      created_at: Time.zone.today.beginning_of_day)
  end

  subject { described_class.first }

  before do
    travel_to(processed_within_a_day_visits.first.created_at + 6.hours) do
      processed_within_a_day_visits.each do |visit|
        accept_visit(visit, visit.slots.first)
      end
    end

    travel_to(processed_within_two_days_visit.created_at + 2.days) do
      accept_visit(
        processed_within_two_days_visit,
        processed_within_two_days_visit.slots.first
      )
    end

    described_class.refresh
  end

  it_behaves_like 'percentile serialisable'

  it { is_expected.to be_readonly }

  describe '#as_json' do
    it "serialises percentalise" do
      as_json = subject.as_json
      expect(as_json[:date]).to eq(Time.zone.today)
      expect(as_json[:ninety_fifth_percentile]).to be_within(0.1).of(2)
      expect(as_json[:median]).to be_within(0.1).of(0.25)
    end
  end
end
