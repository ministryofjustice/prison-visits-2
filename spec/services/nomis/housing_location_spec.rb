require "rails_helper"

RSpec.describe Nomis::HousingLocation do
  let(:unparsed_value) do
    {
      'description' => "some description",
      'levels' => [
        {
          'type' => 'wing', 'value' => 'C'
        },
        {
          'type' => 'landing', 'value' => '2'
        },
        {
          'type' => 'cell', 'value' => '03'
        }
      ]
    }
  end

  subject { described_class.new(unparsed_value) }

  it { is_expected.to respond_to(:description) }
  it { expect(subject.levels).to all(be_instance_of(Nomis::HousingLocation::Level)) }
end
