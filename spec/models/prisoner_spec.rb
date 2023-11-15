require 'rails_helper'

RSpec.describe Prisoner, type: :model do
  subject(:prisoner) { FactoryBot.build(:prisoner, number:) }

  describe '#number' do
    context 'with an inconsistent value' do
      let(:number) { ' a1234Bc ' }

      it 'strips and uppercases the prisoner number on validation' do
        prisoner.valid?
        expect(prisoner.number).to eq('A1234BC')
      end
    end

    context 'with nil value' do
      let(:number) { nil }

      it 'gets handled gracefully' do
        prisoner.valid?
        expect(prisoner.number).to be_nil
      end
    end
  end
end
