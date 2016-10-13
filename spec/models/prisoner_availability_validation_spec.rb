require 'rails_helper'

RSpec.describe PrisonerAvailabilityValidation, type: :model do
  subject do
    described_class.new(offender: offender,
                        requested_dates: requested_dates)
  end

  let(:offender) { Nomis::Offender.new(id: '123') }
  let(:date1) { Date.parse('2016-10-23') }
  let(:date2) { Date.parse('2016-10-22') }
  let(:date3) { Date.parse('2016-10-21') }
  let(:requested_dates) { [date1, date2, date3] }

  describe 'when the NOMIS API is disabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    it 'adds an unknown error for each date' do
      is_expected.to_not be_valid

      requested_dates.each do |date|
        expect(subject.errors[date.to_s]).
          to eq([described_class::PRISONER_AVAILABILITY_UNKNOWN])
      end
    end
  end

  describe 'when the NOMIS API is enabled' do
    context 'and working correctly' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)

        expect_any_instance_of(Nomis::Api).
          to receive(:offender_visiting_availability).
          with(offender_id: offender.id,
               start_date: date3,
               end_date: date1).
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
            expect(subject.date_error(date)).to be_nil
          end
        end
      end

      context 'for the dates that are unavailable' do
        let(:dates) { [date1, date3] }

        it 'adds an error to the missing date' do
          expect(subject.errors[date2.to_s]).
            to eq([described_class::PRISONER_NOT_AVAILABLE])
        end

        context '#date_error' do
          it 'returns the prisoner not available message' do
            expect(subject.date_error(date)).
              to eq(described_class::PRISONER_NOT_AVAILABLE)
          end
        end
      end
    end

    context 'and the API raises an error' do
      before do
        allow_any_instance_of(Nomis::Api).
          to receive(:offender_visiting_availability).
          and_raise(Excon::Errors::Error.new)
      end

      it 'adds unknown errors to all the dates' do
        subject.valid?

        requested_dates.each do |date|
          expect(subject.errors[date.to_s]).
            to eq([described_class::PRISONER_AVAILABILITY_UNKNOWN])
        end
      end
    end
  end
end
