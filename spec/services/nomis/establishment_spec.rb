require "rails_helper"

RSpec.describe Nomis::Establishment, type: :model do
  let(:attributes) do
    {
      'establishment' =>
      {
        'code' => "ISI",
        'desc' => "ISIS HMP/YOI"
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
      before do
        attributes['internal_location'] = "ISI-2-1-1"
      end

      it 'builds the object correctly' do
        expect(subject).
          to have_attributes(
            code: "ISI",
            desc: "ISIS HMP/YOI",
            internal_location: "ISI-2-1-1"
             )
      end
    end
  end
end
