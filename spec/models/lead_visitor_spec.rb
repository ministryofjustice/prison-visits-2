require "rails_helper"

RSpec.describe LeadVisitor do
  subject { build(:lead_visitor) }

  it { is_expected.to be_valid }

  describe 'association' do
    it { is_expected.to belong_to(:visit) }
  end

  describe 'validates' do
    context '#date_of_birth' do
      before do
        subject.date_of_birth = date_of_birth
      end

      context 'when the visitor is 18 or more' do
        let(:date_of_birth) { 18.years.ago }

        it 'validates the lead visitor is at least 18' do
          is_expected.to be_valid
        end
      end

      context 'when the visitor is less than 18' do
        let(:date_of_birth) { 18.years.ago + 1.day }

        it 'validates the lead visitor is at least 18' do
          is_expected.to be_invalid
        end
      end
    end
  end
end
