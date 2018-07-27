require "rails_helper"

RSpec.describe GraphMetricsPresenter do
  let(:prison) { create(:prison) }
  let(:other_prison) { create(:prison) }

  def refresh_views
    VisitCountsByPrisonStateDateAndTimely.refresh
    PercentilesByCalendarDate.refresh
    PercentilesByPrisonAndCalendarDate.refresh
    RejectionPercentageByDay.refresh
  end

  describe 'Percentiles Statistics' do
    let(:visits) { create_list(:visit, 10, prison: prison) }

    before do
      travel_to(visits.first.created_at + 2.days) do
        visits[0..8].each do |visit|
          accept_visit visit, visit.slots.first
        end
      end

      travel_to(visits.first.created_at + 6.days) do
        visit = visits.last
        accept_visit visit, visit.slots.first
      end

      refresh_views
    end

    describe '#percentiles_by_day' do
      it 'returns the distributions of time to process a request' do
        nineteenth = subject.percentiles_by_day.first.percentiles.first / 86_400
        median     = subject.percentiles_by_day.first.percentiles.last / 86_400
        expect(nineteenth).to be_within(1).of(5)
        expect(median).to be_within(1).of(1)
      end
    end

    describe '#percentiles_by_day_for' do
      it 'returns the distributions of time to process a request for a given prison' do
        nineteenth = subject.percentiles_by_day_for(prison).first.percentiles.first / 86_400
        median     = subject.percentiles_by_day_for(prison).first.percentiles.last / 86_400
        expect(nineteenth).to be_within(1).of(5)
        expect(median).to be_within(1).of(1)
      end
    end
  end

  describe 'processing_state breakdown' do
    describe '#visits_per_processing_state_for' do
      let!(:requested_visits)       { create_list :visit, 2, prison: prison }
      let!(:other_requested_visits) { create :visit, prison: other_prison }

      before do
        refresh_views
      end

      it 'returns timeseries for visits per processing state only for the given prison' do
        expect(subject.visits_per_processing_state_for(prison).size).to eq(1)
      end
    end

    describe '#visits_per_processing_state' do
      let!(:requested_visits) { create_list :visit, 5, prison: prison }

      let!(:cancelled_visits) do
        create_list(:visit, 4, prison: prison).map do |visit|
          cancel_visit(visit)
        end
      end

      let!(:booked_visits)  do
        create_list(:visit, 3, prison: prison).map do |visit|
          accept_visit(visit, visit.slots.first)
        end
      end

      let!(:rejected_visits) do
        create_list(:visit, 2, prison: prison).map do |visit|
          reject_visit(visit)
        end
      end

      let!(:withdrawn_visits) do
        create_list(:visit, 1, prison: prison).map do |visit|
          withdraw_visit(visit)
        end
      end

      before do
        refresh_views
      end

      it 'returns timeseries for of visits per processing state' do
        todays_metrics = subject.visits_per_processing_state.first
        expect(todays_metrics.as_json).to eq(date:      Time.zone.today,
                                             requested: BigDecimal(5),
                                             cancelled: BigDecimal(4),
                                             booked:    BigDecimal(3),
                                             rejected:  BigDecimal(2),
                                             withdrawn: BigDecimal(1))
      end
    end
  end

  describe 'timely and overdue' do
    let!(:timely_visits)  { create_list :visit, 2, prison: prison }
    let!(:overdue_visits) { create_list :visit, 3, prison: prison }

    def process_visit(visit, num)
      num.odd? ? reject_visit(visit) : accept_visit(visit, visit.slots.first)
    end

    describe '#timely_and_overdue_for' do
      let!(:other_prison_timely_visits)  { create_list :visit, 1, prison: other_prison }
      let!(:other_prison_overdue_visits) { create_list :visit, 5, prison: other_prison }

      before do
        (timely_visits + other_prison_timely_visits).each_with_index do |visit, i|
          process_visit(visit, i)
        end

        travel_to(Time.zone.today + 6.days) do
          (overdue_visits + other_prison_overdue_visits).each_with_index do |visit, i|
            process_visit(visit, i)
          end
        end

        refresh_views
      end

      it "returns the formatted overdue and timely visits by date for the given prison" do
        timely_and_overdue = subject.timely_and_overdue_for(prison).first
        expect(timely_and_overdue.timely).to eq(2)
        expect(timely_and_overdue.overdue).to eq(3)
      end
    end

    describe '#timely_and_overdue' do
      before do
        timely_visits.each_with_index do |visit, i|
          process_visit(visit, i)
        end

        travel_to(Time.zone.today + 6.days) do
          overdue_visits.each_with_index do |visit, i|
            process_visit(visit, i)
          end
        end

        refresh_views
      end

      it "returns the formatted overdue and timely visits by date" do
        expect(subject.timely_and_overdue.first.as_json).to eq(timely:  BigDecimal(2),
                                                               overdue: BigDecimal(3),
                                                               date:    Time.zone.today)
      end
    end
  end

  describe 'rejection percentage breakdown' do
    describe '#rejection_percentages_for' do
      let!(:no_adult_rejected) do
        create_list(:visit, 2, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::NO_ADULT])
        end
      end

      let!(:child_protection_rejected) do
        create_list(:visit, 1, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::CHILD_PROTECTION_ISSUES])
        end
      end

      let!(:child_protection_rejected_other_prison) do
        create_list(:visit, 2, prison: other_prison).map do |visit|
          reject_visit(visit, [Rejection::CHILD_PROTECTION_ISSUES])
        end
      end

      before do
        refresh_views
      end

      it 'returns the rejection per reason breakdown for the given prison' do
        stat = subject.rejection_percentages_for(prison).first
        expect(stat.no_adult).to eq(66.67)
        expect(stat.child_protection_issues).to eq(33.33)
      end
    end

    describe '#rejection_percentages' do
      let!(:child_protection_rejected) do
        create_list(:visit, 1, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::CHILD_PROTECTION_ISSUES])
        end
      end

      let!(:no_adult_rejected) do
        create_list(:visit, 2, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::NO_ADULT])
        end
      end

      let!(:no_allowance_rejected) do
        create_list(:visit, 3, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::NO_ALLOWANCE])
        end
      end

      let!(:prisoner_details_incorrect_rejected) do
        create_list(:visit, 4, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::PRISONER_DETAILS_INCORRECT])
        end
      end

      let!(:prisoner_moved_rejected) do
        create_list(:visit, 5, prison: prison).map do |visit|
          reject_visit(visit, ['prisoner_moved'])
        end
      end

      let!(:prisoner_non_assiciation_rejected) do
        create_list(:visit, 6, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::PRISONER_NON_ASSOCIATION])
        end
      end

      let!(:prisoner_released_rejected) do
        create_list(:visit, 7, prison: prison).map do |visit|
          reject_visit(visit, ['prisoner_released'])
        end
      end

      let!(:slot_unavailable_rejected) do
        create_list(:visit, 8, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::SLOT_UNAVAILABLE])
        end
      end

      let!(:banned_rejected) do
        create_list(:visit, 9, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::BANNED])
        end
      end

      let!(:not_on_the_list_rejected) do
        create_list(:visit, 10, prison: prison).map do |visit|
          reject_visit(visit, [Rejection::NOT_ON_THE_LIST])
        end
      end

      let!(:duplicate_visit_request_rejected) do
        create_list(:visit, 11, prison: prison).map do |visit|
          reject_visit(visit, ['duplicate_visit_request'])
        end
      end

      before do
        refresh_views
      end

      it 'returns the percentages per rejection reason' do
        stat = subject.rejection_percentages.first
        expect(stat.as_json.except(:date).values.sum).to be_within(0.3).of(100)
        expect(stat.as_json).to eq(date: Time.zone.today,
                                   child_protection_issues:    1.52,
                                   duplicate_visit_request:    16.67,
                                   no_adult:                   3.03,
                                   no_allowance:               4.55,
                                   prisoner_details_incorrect: 6.06,
                                   prisoner_moved:             7.58,
                                   prisoner_non_association:   9.09,
                                   prisoner_out_of_prison:     0,
                                   prisoner_released:          10.61,
                                   slot_unavailable:           12.12,
                                   visitor_banned:             13.64,
                                   visitor_not_on_list:        15.15,
                                   other:                      0,
                                   visitor_other_reason:       0)
      end
    end
  end
end
