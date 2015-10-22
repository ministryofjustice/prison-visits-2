require 'rails_helper'

RSpec.describe Person do
  let(:klass) {
    Class.new.tap { |c|
      c.send :include, NonPersistedModel
      c.send :include, described_class
    }
  }

  subject { klass.new }

  around do |example|
    Timecop.travel Date.new(2015, 10, 8) do
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
end
