RSpec.describe ConcreteSlot do
  subject {
    described_class.new(2015, 10, 23, 14, 0, 15, 30)
  }

  describe 'parse' do
    it 'parses from an ISO 8601 representation' do
      expect(described_class.parse('2015-10-23T14:00/15:30')).to eq(subject)
    end

    it 'raises an ArgumentError if parsing fails' do
      expect {
        described_class.parse('JUNK')
      }.to raise_exception(ArgumentError)
    end
  end

  describe 'iso8601' do
    it 'generates an ISO 8601 representation' do
      expect(subject.iso8601).to eq('2015-10-23T14:00/15:30')
    end
  end

  describe 'begin_at' do
    subject {
      super().begin_at
    }

    it { is_expected.to be_a(Time) }
    it { is_expected.to have_attributes(utc_offset: 0) }
    it { is_expected.to have_attributes(year: 2015, month: 10, day: 23) }
    it { is_expected.to have_attributes(hour: 14, min: 0, sec: 0) }
  end

  describe 'end_at' do
    subject {
      super().end_at
    }

    it { is_expected.to be_a(Time) }
    it { is_expected.to have_attributes(utc_offset: 0) }
    it { is_expected.to have_attributes(year: 2015, month: 10, day: 23) }
    it { is_expected.to have_attributes(hour: 15, min: 30, sec: 0) }
  end

  describe 'duration' do
    it 'is the difference between begin and end times in seconds' do
      expect(subject.duration).to eq(5400)
    end
  end
end
