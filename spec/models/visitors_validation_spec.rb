require 'rails_helper'

RSpec.describe VisitorsValidation do
  let(:prison) { FactoryBot.create(:prison) }

  let(:lead_dob) { 18.years.ago.to_date }
  let(:dobs) { [lead_dob] }

  subject do
    described_class.new(lead_date_of_birth: lead_dob,
                        dates_of_birth: dobs,
                        prison:)
  end

  describe 'validations' do
    context 'when valid' do
      it { is_expected.to be_valid }

      it 'has no error keys' do
        subject.valid?
        expect(subject.error_keys).to be_empty
      end
    end

    context 'when the lead visitor is a minor' do
      let(:lead_dob) { 17.years.ago.to_date }

      it { is_expected.not_to be_valid }

      it "has 'lead_visitor_age' as an error key" do
        subject.valid?
        expect(subject.error_keys).to eq(['lead_visitor_age'])
      end
    end

    context 'when there are too many visitors' do
      let(:dobs) { 7.times.map { 1.day.ago.to_date } }

      it { is_expected.not_to be_valid }

      it "has 'too_many_visitors' as an error key" do
        subject.valid?
        expect(subject.error_keys).to eq(['too_many_visitors'])
      end
    end

    context 'when there are too many adults' do
      let(:dobs) do
        (Prison::MAX_ADULTS + 1).times.map {
          prison.adult_age.years.ago.to_date
        }
      end

      it { is_expected.not_to be_valid }

      it "has 'too_many_adults' as an error key" do
        subject.valid?
        expect(subject.error_keys).to eq(['too_many_adults'])
      end
    end
  end
end
