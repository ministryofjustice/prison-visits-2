require 'rails_helper'

RSpec.describe Person do
  subject {
    described_module = described_class
    Class.new {
      include NonPersistedModel
      include described_module

      attribute :first_name, String
      attribute :last_name, String
      attribute :date_of_birth, Date

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

  describe 'minimum_date_of_birth' do
    it 'gives a day of 1st' do
      expect(subject.minimum_date_of_birth.day).to eq(1)
    end

    it 'gives a month of January' do
      expect(subject.minimum_date_of_birth.month).to eq(1)
    end

    it 'gives a year of 120 years ago' do
      expect(subject.minimum_date_of_birth.year).to eq(1895)
    end
  end

  describe 'maximum_date_of_birth' do
    it 'gives a day of 31st' do
      expect(subject.maximum_date_of_birth.day).to eq(31)
    end

    it 'gives a month of December' do
      expect(subject.maximum_date_of_birth.month).to eq(12)
    end

    it 'gives a year of this year' do
      expect(subject.maximum_date_of_birth.year).to eq(2015)
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
