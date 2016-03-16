require 'rails_helper'

RSpec.describe WeeklyMetricsConfirmedCsvExporter do
  let(:weeks) { 2 }
  let(:instance) { described_class.new(weeks: weeks) }

  describe '#to_csv' do
    let(:prison1) { create(:prison, name: 'A Prison') }
    let(:prison2) { create(:prison, name: 'B Prison') }
    let(:prison3) { create(:prison, name: 'C Prison') }
    let(:week_ago) { 1.week.ago }
    let(:two_weeks_ago) { 2.weeks.ago }

    let!(:recent_confirmed_visit) do
      create(:booked_visit, prison: prison3)
    end
    let!(:week_old_confirmed_visit) do
      create(:booked_visit, prison: prison1, created_at: week_ago)
    end
    let!(:two_week_old_confirmed_visit) do
      create(:booked_visit, prison: prison2, created_at: two_weeks_ago)
    end

    subject { instance.to_csv }

    it 'returns a CSV string' do
      week1 = week_ago.beginning_of_week.to_date.to_s
      week2 = two_weeks_ago.beginning_of_week.to_date.to_s

      expect(subject).to eq(<<-CSV)
Prison,#{week1},#{week2}
A Prison,1,0
B Prison,0,1
C Prison,0,0
CSV
    end
  end
end
