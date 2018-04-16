require "rails_helper"

RSpec.describe HousingLocationType do
  let(:value) do
    {
      "description" => "BMI-C-2-03",
      "levels" => [
        { "type" => "Wing",    "value" => "C" },
        { "type" => "Landing", "value" => "2" },
        { "type" => "Cell",    "value" => "03" }
      ]
    }
  end

  subject { described_class.new }

  describe '#cast' do
    let(:casted) { subject.cast(value) }

    context 'when give a hash' do
      it { expect(casted.description).to eq(value['description']) }
      it { expect(casted.levels).to all(be_instance_of(Nomis::HousingLocation::Level)) }
    end
  end
end
