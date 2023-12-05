require 'rails_helper'

RSpec.describe AgeValidator do
  subject do
    described_class.new(attributes: [:date_of_birth])
  end

  let(:model) {
    Class.new {
      include MemoryModel

      def self.model_name
        ActiveModel::Name.new(self, nil, 'thing')
      end
      attribute :date_of_birth, :accessible_date
      validates :date_of_birth, presence: true, age: true
    }.new
  }

  before do
    subject.validate_each(model, :date_of_birth, value)
  end

  context "when error if not a date" do
    let(:value) { 'Random String' }

    it 'one error message' do
      expect(model.errors.count).to eq(1)
    end

    it 'correct error message' do
      expect(model.errors.full_messages).to include('Date of birth is an invalid date')
    end
  end

  context "when error if not a valid date" do
    let(:value) { AccessibleDate.new(year: 2017, month: 11, day: 31) }

    it 'one error message' do
      expect(model.errors.count).to eq(1)
    end

    it 'correct error message' do
      expect(model.errors.full_messages).to include('Date of birth is an invalid date')
    end
  end

  context "when error if too old" do
    let(:value) { Date.new(1700, 1, 1) }

    it 'one error message' do
      expect(model.errors.count).to eq(1)
    end

    it 'correct error message' do
      expect(model.errors.full_messages).to include('Date of birth must be less than 120 years ago')
    end
  end

  context "when it allows legitimate date of birth" do
    let(:value) { Time.zone.today - 10 }

    it 'no error message' do
      expect(model.errors.count).to eq(0)
    end
  end
end
