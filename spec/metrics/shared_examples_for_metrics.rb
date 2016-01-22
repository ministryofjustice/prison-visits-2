RSpec.shared_examples 'create visits without dates' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  let!(:luna_visits_without_dates) do
    make_visits(luna)
  end

  let!(:mars_visits_without_dates) do
    make_visits(mars)
  end

  def make_visits(prison)
    [:visit, :booked_visit, :rejected_visit,
     :cancelled_visit, :withdrawn_visit].each do |visit_type|
      create(visit_type, prison: prison)
    end
  end
end

RSpec.shared_examples 'create visits with dates' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  let(:luna_visits_with_dates) do
    make_visits(luna)
  end

  let(:mars_visits_with_dates) do
    make_visits(mars)
  end

  def make_visits(prison)
    create(:visit, created_at: Time.zone.local(2016, 2, 1), prison: prison)
    create(:visit, created_at: Time.zone.local(2016, 2, 8), prison: prison)

    create(:booked_visit, created_at: Time.zone.local(2016, 2, 1), prison: prison)
    create(:booked_visit, created_at: Time.zone.local(2016, 2, 8), prison: prison)

    create(:rejected_visit, created_at: Time.zone.local(2016, 2, 1), prison: prison)
    create(:rejected_visit, created_at: Time.zone.local(2016, 2, 15), prison: prison)

    # Due to percularities of isoyear, this will show up as the last week of 2015
    # in the calendar week count.
    create(:cancelled_visit, created_at: Time.zone.local(2016, 1, 1), prison: prison)
  end
end

RSpec.shared_examples 'create and process visits timed by seconds' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  before do
    [luna, mars].each do |prison|
      visits = []
      travel_to Time.zone.local(2016, 3, 1, 13, 0, 0) do
        visits = create_list(:visit, 10, prison: prison)
      end

      visits.each_with_index do |visit, i|
        seconds = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55].fetch(i)
        travel_to Time.zone.local(2016, 3, 1, 13, 0, seconds) do
          visit.accept!
        end
      end
    end
  end
end

RSpec.shared_examples 'create and process visits with dates' do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  let(:luna_visits_with_dates) do
    make_visits(luna)
  end

  let(:mars_visits_with_dates) do
    make_visits(mars)
  end

  def make_visits(prison)
    [1, 8, 15].each do |day|
      visits = create_list(:visit, 3, created_at: Time.zone.local(2016, 2, day), prison: prison)

      visits.each_with_index do |visit, index|
        days = [3, 5, 9].fetch(index)
        processed_on = visit.created_at + days.day
        travel_to processed_on do
          visit.accept!
        end
      end
    end
  end
end
