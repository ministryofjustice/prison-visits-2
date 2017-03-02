require 'rails_helper'
require 'nomis/client'

RSpec.describe PrisonerAvailabilityValidation, type: :model do
  subject do
    described_class.new(offender: offender,
                        requested_dates: requested_dates)
  end

  let(:offender) { Nomis::Offender.new(id: '123') }
  let(:date1) { 2.days.from_now.to_date }
  let(:date2) { 1.day.from_now.to_date }
  let(:date3) { 3.days.from_now.to_date }
  let(:requested_dates) { [date1, date2, date3] }

  describe 'when the NOMIS API is disabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
      subject.valid?
    end

    it "doesn't add errors to the dates" do
      requested_dates.each do |date|
        expect(subject.errors[date.to_s]).to be_empty
      end
    end

    it 'is unknown result' do
      expect(subject).to be_unknown_result
    end
  end

  describe 'when the NOMIS API is enabled' do
    context 'and the api returns an error' do
      before do
        expect_any_instance_of(Nomis::Client).
          to receive(:get).and_raise(Nomis::APIError)
      end

      it 'adds no errors for any date' do
        is_expected.to be_valid

        requested_dates.each do |date|
          expect(subject.errors[date.to_s]).to be_empty
        end
      end

      it 'is unknown result' do
        subject.valid?

        expect(subject).to be_unknown_result
      end
    end

    context 'and working correctly with valid dates' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)

        expect_any_instance_of(Nomis::Api).
          to receive(:offender_visiting_availability).
          with(offender_id: offender.id,
               start_date: date2,
               end_date: date3).
          and_return(Nomis::PrisonerAvailability.new(dates: dates))

        subject.valid?
      end

      context 'for the dates that are available' do
        let(:dates) { [date1] }

        it 'does not add an error to the date' do
          expect(subject.errors[date1.to_s]).to be_blank
        end

        context '#date_error' do
          it 'returns nothing' do
            expect(subject.date_error(date1)).to be_nil
          end
        end

        it { is_expected.not_to be_unknown_result }
      end

      context 'for the dates that are unavailable' do
        let(:dates) { [date1, date3] }

        it 'adds an error to the missing date' do
          expect(subject.errors[date2.to_s]).
            to eq([described_class::PRISONER_NOT_AVAILABLE])
        end

        context '#date_error' do
          it 'returns the prisoner not available message' do
            expect(subject.date_error(date2)).
              to eq(described_class::PRISONER_NOT_AVAILABLE)
          end
        end

        it { is_expected.not_to be_unknown_result }
      end
    end

    context 'and API enabled with invalid dates' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)
      end

      context 'with all the dates in the past' do
        let(:date1) { 1.day.ago.to_date }
        let(:date2) { 2.days.ago.to_date }
        let(:date3) { 3.days.ago.to_date }

        # We return the dates as valid because it doesn't make sense to
        # communicate that the prisoner is unavailable just because the date is
        # in the past. Another validator will be responsible for that.
        it 'returns all the dates' do
          expect_any_instance_of(Nomis::Api).
            not_to receive(:offender_visiting_availability)

          subject.valid?

          requested_dates.each do |date|
            expect(subject.date_error(date)).to be_nil
          end
        end

        it { is_expected.not_to be_unknown_result }
      end

      context 'with some dates in the past' do
        let(:date1) { 1.day.ago.to_date }
        let(:date2) { 61.days.from_now.to_date }

        before do
          expect_any_instance_of(Nomis::Api).
            to receive(:offender_visiting_availability).
            with(offender_id: offender.id,
                 start_date: date3,
                 end_date: date3).
            and_return(Nomis::PrisonerAvailability.new(dates: []))
        end

        it 'filters out invalid dates' do
          subject.valid?

          expect(subject.date_error(date1)).to be_nil
          expect(subject.date_error(date2)).to be_nil
          expect(subject.date_error(date3)).
            to eq(described_class::PRISONER_NOT_AVAILABLE)
        end

        it { is_expected.not_to be_unknown_result }
      end
    end

    context 'and API enabled with invalid offender' do
      let(:offender) { Nomis::NullOffender.new }

      it { is_expected.to be_unknown_result }
    end
  end
end
