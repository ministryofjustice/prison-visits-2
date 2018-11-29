require 'rails_helper'

RSpec.describe VisitorsStep do
  let(:prison) { build(:prison) }

  subject { described_class.new(prison: prison) }

  describe "email_address=" do
    it 'strips whitespace' do
      subject.email_address = ' email@example.com '
      expect(subject.email_address).to eq('email@example.com')
    end
  end

  describe 'backfilled_visitors' do
    it 'includes supplied visitors' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'date_of_birth' => { 'day' => '1', 'month' => '2', 'year' => '1980' }
        },
        '1' => {
          'first_name' => 'John',
          'last_name' => 'Johnson',
          'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
        }
      }
      first_visitor = subject.backfilled_visitors[0]
      expect(first_visitor.first_name).to eq('Bob')
      expect(first_visitor.last_name).to eq('Roberts')
      expect(first_visitor.date_of_birth).to eq(Date.new(1980, 2, 1))

      second_visitor = subject.backfilled_visitors[1]
      expect(second_visitor.first_name).to eq('John')
      expect(second_visitor.last_name).to eq('Johnson')
      expect(second_visitor.date_of_birth).to eq(Date.new(1990, 4, 3))
    end

    it 'ignores more than Prison::MAX_VISITORS visitors' do
      subject.visitors_attributes = 7.times.map { |n|
        [
          n.to_s,
          {
            'first_name' => 'John',
            'last_name' => 'Johnson',
            'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
          }
        ]
      }.to_h
      expect(subject.backfilled_visitors.count).to eq(6)
    end

    it 'returns blank visitors to make up 6' do
      subject.visitors_attributes = {}
      expect(subject.backfilled_visitors.count).to eq(6)
    end

    it 'includes and validates one visitor if none supplied' do
      subject.visitors_attributes = {}
      subject.valid?
      expect(subject.backfilled_visitors[0].errors).not_to be_empty
    end

    it 'does not validate blank additional visitors' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => '',
          'last_name' => '',
          'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
        },
        '1' => {
          'first_name' => '',
          'last_name' => '',
          'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
        }
      }
      subject.validate
      expect(subject.backfilled_visitors[1].errors).to be_empty
    end
  end

  describe 'additional_visitor_count' do
    it 'is one less than the number of visitors supplied' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'date_of_birth' => { 'day' => '1', 'month' => '2', 'year' => '1980' }
        },
        '1' => {
          'first_name' => 'John',
          'last_name' => 'Johnson',
          'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
        },
        '2' => {
          'first_name' => '',
          'last_name' => '',
          'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
        }
      }
      expect(subject.additional_visitor_count).to eq(1)
    end
  end

  describe 'visitors' do
    it 'returns only visitors assigned with at least one field' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'date_of_birth' => { 'day' => '1', 'month' => '2', 'year' => '1980' }
        },
        '1' => {
          'first_name' => '',
          'last_name' => '',
          'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
        },
        '2' => {
          'first_name' => '',
          'last_name' => '',
          'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
        }
      }

      expect(subject.visitors.count).to eq(2)
    end

    it 'always returns at least one visitor' do
      subject.visitors_attributes = {}
      expect(subject.visitors.count).to eq(1)
    end

    it 'ignores more than Prison::MAX_VISITORS visitors' do
      subject.visitors_attributes = 7.times.map { |n|
        [
          n.to_s,
          {
            'first_name' => 'John',
            'last_name' => 'Johnson',
            'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
          }
        ]
      }.to_h
      expect(subject.visitors.count).to eq(6)
    end
  end

  describe 'valid?' do
    before do
      subject.email_address = 'user@test.example.com'
      subject.phone_no = '01154960123'
    end

    it 'is true if the step is valid and all visitors are valid' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'date_of_birth' => { 'day' => '1', 'month' => '2', 'year' => '1980' }
        },
        '1' => {
          'first_name' => 'John',
          'last_name' => 'Johnson',
          'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
        }
      }

      expect(subject).to be_valid
    end

    it 'is false if a visitor is invalid' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'date_of_birth' => { 'day' => '1', 'month' => '2', 'year' => '1980' }
        },
        '1' => {
          'first_name' => '',
          'last_name' => 'Johnson',
          'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
        }
      }

      expect(subject).not_to be_valid
    end

    it 'is false if there are no visitors' do
      subject.visitors_attributes = {}
      expect(subject).not_to be_valid
    end

    it 'validates all objects even if one is invalid' do
      subject.email_address = 'invalid'
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => '',
          'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
        },
        '1' => {
          'first_name' => 'John',
          'last_name' => '',
          'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
        }
      }
      subject.validate
      expect(subject.backfilled_visitors[0].errors).not_to be_empty
      expect(subject.backfilled_visitors[1].errors).not_to be_empty
      expect(subject.errors).not_to be_empty
    end
  end

  context 'with age-related validations' do
    let(:prison) { build(:prison, adult_age: 13) }

    around do |example|
      travel_to Date.new(2015, 12, 1) do
        example.call
      end
    end

    it 'is valid if there are 3 adult and 3 child visitors' do
      subject.visitors = [
        {
          first_name: 'John',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '1990' # First visitor > 18
          }
        },
        {
          first_name: 'Jane',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '2002' # 13 today
          }
        },
        {
          first_name: 'Jim',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '2002' # 13 today
          }
        },
        {
          first_name: 'Joe',
          last_name: 'Johnson',
          date_of_birth: {
            day: '2', month:  '12', year:  '2002' # 13 tomorrow
          }
        },
        {
          first_name: 'Jessica',
          last_name: 'Johnson',
          date_of_birth: {
            day: '2', month:  '12', year:  '2002' # 13 tomorrow
          }
        },
        {
          first_name: 'Jerry',
          last_name: 'Johnson',
          date_of_birth: {
            day: '2', month:  '12', year:  '2002' # 13 tomorrow
          }
        }
      ]
      subject.validate
      expect(subject.errors).not_to have_key(:general)
    end

    it 'is invalid if there are too many adult visitors' do
      subject.visitors = [
        {
          first_name: 'John',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '1970'
          }
        },
        {
          first_name: 'Jane',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '2002' # 13 today
          }
        },
        {
          first_name: 'Jim',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '2002' # 13 today
          }
        },
        {
          first_name: 'Joe',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '2002' # 13 today
          }
        },
        {
          first_name: 'Jessica',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '2002' # 13 today
          }
        },
        {
          first_name: 'Jerry',
          last_name: 'Johnson',
          date_of_birth: {
            day: '1', month:  '12', year:  '2002' # 13 today
          }
        }
      ]
      subject.validate
      expect(subject.errors[:general]).to include(
        'You can book a maximum of 3 visitors over the age of 13 on this visit'
      )
    end

    it 'is invalid if there is no adult visitor' do
      subject.visitors = [
        {
          first_name: 'Joe',
          last_name: 'Johnson',
          date_of_birth: {
            day: '2', month:  '12', year:  '2002' # 13 tomorrow
          }
        },
        {
          first_name: 'Jessica',
          last_name: 'Johnson',
          date_of_birth: {
            day: '2', month:  '12', year:  '2002' # 13 tomorrow
          }
        }
      ]
      subject.validate
      expect(subject.errors[:general]).to include(
        'The person requesting the visit must be over the age of 18'
      )
    end
  end
end
