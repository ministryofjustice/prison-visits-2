require "rails_helper"

RSpec.describe Nomis::Offender, type: :model do
  let(:noms_id) { 'A1459AE' }

  it { is_expected.to validate_presence_of :id }
  it { is_expected.to validate_presence_of :noms_id }

  subject { described_class.new(noms_id: noms_id) }

  context 'with an unormalised noms_id' do
    let(:noms_id) { 'A1234bc ' }

    it 'normalises the noms_id' do
      expect(subject.noms_id).to eq('A1234BC')
    end
  end

  describe '#iep_level' do
    context 'with a successful API call' do
      describe 'with an iep level' do
        before do
          mock_nomis_with(
            :lookup_offender_details,
            Nomis::Offender::Details.new(
              iep_level: { 'code' => 'STD', 'desc' => 'Standard' }
            )
          )
        end

        it { expect(subject.iep_level).to eq('Standard') }
      end

      describe 'when the offender does not have an iep_level' do
        before do
          mock_nomis_with(
            :lookup_offender_details,
            Nomis::Offender::Details.new(iep_level: nil)
          )
        end

        it { expect(subject.iep_level).to be nil }
      end
    end

    context 'with a unsuccessful API call' do
      before do
        simulate_api_error_for(:lookup_offender_details)
      end

      it { expect(subject.iep_level).to be nil }
    end
  end

  describe '#imprisonment_status' do
    context 'with a successful API call' do
      before do
        mock_nomis_with(
          :lookup_offender_details,
          Nomis::Offender::Details.new(
            imprisonment_status: { 'code' => 'RX', 'desc' => 'Remanded to Magistrates Court' }
          )
        )
      end

      it { expect(subject.imprisonment_status).to eq('Remanded to Magistrates Court') }
    end

    context 'with a unsuccessful API call' do
      before do
        simulate_api_error_for(:lookup_offender_details)
      end

      it { expect(subject.imprisonment_status).to be nil }
    end
  end
end
