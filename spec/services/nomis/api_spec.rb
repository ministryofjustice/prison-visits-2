require 'rails_helper'

RSpec.describe Nomis::Api do
  subject { described_class.instance }

  describe 'lookup_active_offender', vcr: { cassette_name: 'lookup_active_offender' } do
    let(:params) {
      {
        noms_id: 'A1459AE',
        date_of_birth: Date.parse('1976-06-12')
      }
    }

    subject { super().lookup_active_offender(params) }

    it 'returns and offender if the data matches' do
      expect(subject).to be_kind_of(Nomis::Offender)
      expect(subject.id).to eq(1_055_827)
    end

    it 'returns nil if the data does not match', vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
      params[:noms_id] = 'Z9999ZZ'
      expect(subject).to be_nil
    end
  end
end
