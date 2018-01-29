require 'rails_helper'

RSpec.describe Person do
  subject {
    described_module = described_class
    Class.new {
      include MemoryModel
      include described_module
      attribute :first_name, :string
      attribute :last_name, :string
      attribute :date_of_birth, :date

      def self.model_name
        ActiveModel::Name.new(self, nil, 'thing')
      end
    }.new
  }

  around do |example|
    travel_to Date.new(2015, 10, 8) do
      example.run
    end
  end

  describe 'age' do
    it 'is nil when date of birth is nil' do
      expect(subject.age).to be_nil
    end

    it 'calculates age' do
      subject.date_of_birth = Date.new(1995, 10, 8)
      expect(subject.age).to eq(20)
    end
  end

  describe 'full_name' do
    it 'joins first and last name' do
      subject.first_name = 'Oscar'
      subject.last_name = 'Wilde'
      expect(subject.full_name).to eq('Oscar Wilde')
    end
  end

  describe 'anonymized_name' do
    it 'uses only the first letter of the last name' do
      subject.first_name = 'Oscar'
      subject.last_name = 'Wilde'
      expect(subject.anonymized_name).to eq('Oscar W')
    end
  end
end
