require "rails_helper"

RSpec.describe Nomis::Offender, type: :model do
  it { is_expected.to validate_presence_of :id }
  it { is_expected.to validate_presence_of :noms_id }

  context 'with an unormalised noms_id' do
    before do
      subject.noms_id = 'A1234bc '
    end

    it 'normalises the noms_id' do
      expect(subject.noms_id).to eq('A1234BC')
    end
  end
end
