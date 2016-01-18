require 'rails_helper'

RSpec.describe Counters do
  context 'without dates' do
    before do
      luna = create(:prison, name: 'Lunar Penal Colony')
      mars = create(:prison, name: 'Martian Penal Colony')
      [:visit, :booked_visit, :rejected_visit,
       :cancelled_visit, :withdrawn_visit].each do |visit_type|
        create(visit_type, prison: luna)
        create(visit_type, prison: mars)
      end
    end

    describe Counters::CountVisits do
      it 'returns a total count of all visits' do
        expect(described_class.run).to eq(10)
      end
    end

    describe Counters::CountVisitsByState do
      it 'returns a total count of all visits' do
        expect(described_class.run).to eq('booked' => 2,
                                          'cancelled' => 2,
                                          'withdrawn' => 2,
                                          'rejected' => 2,
                                          'requested' => 2)
      end
    end

    describe Counters::CountVisitsByPrisonAndState do
      it 'returns counts by state that are grouped by prison' do
        expect(described_class.run).to be ==
          { 'Lunar Penal Colony' =>
            { 'requested' => 1,
              'booked' => 1,
              'rejected' => 1,
              'cancelled' => 1,
              'withdrawn' => 1
            },
            'Martian Penal Colony' =>
            { 'requested' => 1,
              'booked' => 1,
              'rejected' => 1,
              'cancelled' => 1,
              'withdrawn' => 1
            }
        }
      end
    end
  end

  context 'by dates' do
    before do
      luna = create(:prison, name: 'Lunar Penal Colony')
      create(:visit, created_at: Time.zone.local(2016, 2, 1), prison: luna)
      create(:visit, created_at: Time.zone.local(2016, 2, 8), prison: luna)

      create(:booked_visit, created_at: Time.zone.local(2016, 2, 1), prison: luna)
      create(:booked_visit, created_at: Time.zone.local(2016, 2, 8), prison: luna)

      create(:rejected_visit, created_at: Time.zone.local(2016, 2, 1), prison: luna)
      create(:rejected_visit, created_at: Time.zone.local(2016, 2, 15), prison: luna)

      # Due to percularities of isoyear, this will show up as the last week of 2015
      # in the calendar week count.
      create(:cancelled_visit, created_at: Time.zone.local(2016, 1, 1), prison: luna)
    end

    describe Counters::CountVisitsByPrisonAndCalendarWeek do
      it 'returns counts by state that are grouped by prison, year, and week' do
        expect(described_class.run).to be ==
          { 'Lunar Penal Colony' =>
            {
              2015 => {
                53 => {
                  'cancelled' => 1
                }
              },
              2016 => {
                5 => {
                  'requested' => 1,
                  'rejected' => 1,
                  'booked' => 1
                },
                6 => {
                  'requested' => 1,
                  'booked' => 1
                },
                7 => {
                  'rejected' => 1
                }
              }
            }
        }
      end
    end

    describe Counters::CountVisitsByPrisonAndCalendarDate do
      it 'returns counts by state that are grouped by prison, year, and week' do
        expect(described_class.run).to be ==
          { 'Lunar Penal Colony' =>
            {
              2016 => {
                1 => {
                  1 => {
                    'cancelled' => 1
                  }
                },
                2 => {
                  1 => {
                    'requested' => 1,
                    'booked' => 1,
                    'rejected' => 1
                  },
                  8 => {
                    'requested' => 1,
                    'booked' => 1
                  },
                  15 => {
                    'rejected' => 1
                  }
                }
              }
            }
        }
      end
    end
  end
end
