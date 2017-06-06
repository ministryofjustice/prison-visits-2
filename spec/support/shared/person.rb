RSpec.shared_examples 'a person' do
  describe 'validations' do
    let(:min_date_of_birth) { Person::MAX_AGE.years.ago.beginning_of_year.to_date }
    let(:max_date_of_birth) { Time.zone.today.end_of_year }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_inclusion_of(:date_of_birth).in_range(min_date_of_birth..max_date_of_birth) }
  end
end
