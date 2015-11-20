require 'rails_helper'

RSpec.describe Names do
  context 'without prefix' do
    subject {
      described_module = described_class
      Class.new {
        attr_accessor :first_name, :last_name
        extend described_module
        enhance_names
      }.new
    }

    describe 'anonymized_name' do
      it 'uses only the first letter of the last name' do
        subject.first_name = 'Oscar'
        subject.last_name = 'Wilde'
        expect(subject.anonymized_name).to eq('Oscar W')
      end
    end

    describe 'full_name' do
      it 'joins first and last name' do
        subject.first_name = 'Oscar'
        subject.last_name = 'Wilde'
        expect(subject.full_name).to eq('Oscar Wilde')
      end
    end
  end

  context 'with prefix' do
    subject {
      described_module = described_class
      Class.new {
        attr_accessor :foo_first_name, :foo_last_name
        extend described_module
        enhance_names prefix: :foo
      }.new
    }

    describe 'anonymized_name' do
      it 'uses only the first letter of the last name' do
        subject.foo_first_name = 'Oscar'
        subject.foo_last_name = 'Wilde'
        expect(subject.foo_anonymized_name).to eq('Oscar W')
      end
    end

    describe 'full_name' do
      it 'joins first and last name' do
        subject.foo_first_name = 'Oscar'
        subject.foo_last_name = 'Wilde'
        expect(subject.foo_full_name).to eq('Oscar Wilde')
      end
    end
  end
end
