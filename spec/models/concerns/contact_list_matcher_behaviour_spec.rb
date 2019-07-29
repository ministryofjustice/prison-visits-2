require "rails_helper"

RSpec.describe ContactListMatcherBehaviour do
  subject do
    described_module = described_class

    unless defined?(TestMatcher)
      stub_const("TestMatcher", Class.new do
        include described_module
      end)
    end

    TestMatcher.new
  end

  describe '#category' do
    it 'returns the model name humanized' do
      expect(subject.category).to eq('Test matcher')
    end
  end

  describe '#add' do
    let(:contacts) { 'Bob' }

    context 'when adding a single contact' do
      it 'adds the contact to contact list' do
        expect{
          subject.add(1, contacts)
        }.to change(subject, :contacts).from([]).to(['Bob'])
      end
    end

    context 'when adding a several contacts' do
      context 'with the same score' do
        let(:contacts) { %w[Bob Alice] }

        it 'adds contacts to contact list' do
          expect{
            subject.add(1, contacts)
          }.to change(subject, :contacts).from([]).to(%w[Bob Alice])
        end
      end

      context 'with different scores' do
        let(:contacts_one)      { %w[Mark Jez] }
        let(:contacts_half_one) { ['Super Hans'] }

        it 'adds contacts to contact list' do
          expect{
            subject.add(1, contacts_one)
            subject.add(0.5, contacts_half_one)
          }.to change(subject, :contacts).from([]).to(['Mark', 'Jez', 'Super Hans'])
        end
      end
    end
  end

  describe '#any?' do
    context 'with no contacts' do
      it { is_expected.not_to be_any }
    end

    context 'with a contact' do
      before { subject.add 1, 'Jez' }

      it { is_expected.to be_any }
    end
  end
end
