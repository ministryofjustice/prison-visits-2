require "rails_helper"

RSpec.describe Nomis::Establishment, type: :model do
  let(:attributes) do
    {
      'establishment' =>
      {
        'code' => "ISI",
        'desc' => "ISIS HMP/YOI"
      },
      "housing_location" => {
        "description" => "ISI-2-1-1",
        "levels" => [
          { "type" => "Wing",    "value" => "2" },
          { "type" => "Landing", "value" => "1" },
          { "type" => "Cell",    "value" => "1" }
        ]
      }

    }
  end

  subject { described_class.build(attributes) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of :code }
  end

  describe '.build' do
    context 'when internal location is not nested under the establishment key' do
      it 'builds the object correctly' do
        expect(subject)
          .to have_attributes(
            code: "ISI",
            desc: "ISIS HMP/YOI",
            housing_location: instance_of(Nomis::HousingLocation)
             )
      end
    end
  end
end
