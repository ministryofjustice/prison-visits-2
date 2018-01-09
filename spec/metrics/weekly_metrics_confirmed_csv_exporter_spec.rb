require 'rails_helper'

RSpec.describe WeeklyMetricsConfirmedCsvExporter do
  let(:instance) { described_class.new(dates_to_export) }

  describe '#to_csv' do
    let(:prison1) { create(:prison, name: 'A Prison') }
    let(:prison2) { create(:prison, name: 'B Prison') }
    let(:prison3) { create(:prison, name: 'C Prison') }
    let(:week_ago) { 1.week.ago.beginning_of_week + 10.hours }
    let(:two_weeks_ago) { 2.weeks.ago.beginning_of_week + 10.hours }
    let(:dates_to_export) { [week_ago.to_date, two_weeks_ago.to_date] }

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

    context 'with data from the 2 different years ' do
      around do |ex|
        travel_to(Date.new(2018, 1, 9)) { ex.run }
      end

      it 'returns a CSV string' do
        week1 = week_ago.to_date.to_s
        week2 = two_weeks_ago.to_date.to_s

        expect(subject).to eq(<<~CSV)
          Prison,#{week1},#{week2}
          A Prison,1,0
          B Prison,0,1
          C Prison,0,0
        CSV
      end
    end

    context 'with data from the current year' do
      around do |ex|
        travel_to(Time.zone.local(2018, 6, 9, 16, 0)) { ex.run }
      end

      it 'returns a CSV string' do
        week1 = week_ago.to_date.to_s
        week2 = two_weeks_ago.to_date.to_s

        expect(subject).to eq(<<~CSV)
          Prison,#{week1},#{week2}
          A Prison,1,0
          B Prison,0,1
          C Prison,0,0
        CSV
      end
    end
  end
end
