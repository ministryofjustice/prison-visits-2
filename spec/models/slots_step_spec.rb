require 'rails_helper'

RSpec.describe SlotsStep, type: :model do
  describe 'validation of options' do
    subject { described_class.new(prison: prison) }

    let(:slot) { ConcreteSlot.new(2015, 1, 2, 9, 0, 10, 0) }
    let(:prison) { double(Prison, available_slots: [slot]) }

    describe 'option 1' do
      it 'is valid if the slot exists' do
        subject.option_1 = '2015-01-02T09:00/10:00'
        subject.validate
        expect(subject.errors).not_to have_key(:option_1)
      end

      it 'is invalid if the slot does not exist' do
        subject.option_1 = '2015-01-02T09:00/11:00'
        subject.validate
        expect(subject.errors).to have_key(:option_1)
      end

      it 'is invalid if empty' do
        subject.option_1 = ''
        subject.validate
        expect(subject.errors).to have_key(:option_1)
      end
    end

    describe 'option_2' do
      it 'is valid if the slot exists' do
        subject.option_2 = '2015-01-02T09:00/10:00'
        subject.validate
        expect(subject.errors).not_to have_key(:option_2)
      end

      it 'is invalid if the slot does not exist' do
        subject.option_2 = '2015-01-02T09:00/11:00'
        subject.validate
        expect(subject.errors).to have_key(:option_2)
      end

      it 'is valid if empty' do
        subject.option_2 = ''
        subject.validate
        expect(subject.errors).not_to have_key(:option_2)
      end
    end

    describe 'option_3' do
      it 'is valid if the slot exists' do
        subject.option_3 = '2015-01-02T09:00/10:00'
        subject.validate
        expect(subject.errors).not_to have_key(:option_3)
      end

      it 'is invalid if the slot does not exist' do
        subject.option_3 = '2015-01-02T09:00/11:00'
        subject.validate
        expect(subject.errors).to have_key(:option_3)
      end

      it 'is valid if empty' do
        subject.option_3 = ''
        subject.validate
        expect(subject.errors).not_to have_key(:option_3)
      end
    end
  end
end
