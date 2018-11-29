RSpec.describe RecurringSlot do
  context 'when parsed from a valid description' do
    subject { described_class.parse('0930-1445') }

    it {
      expect(subject).to have_attributes(
        begin_hour: 9,
        begin_minute: 30,
        end_hour: 14,
        end_minute: 45
      )
    }
  end

  context 'when parsed from an invalid description' do
    it 'raises an exception' do
      expect {
        described_class.parse('THIS IS JUNK')
      }.to raise_exception(described_class::ParseError)
    end
  end

  context 'when parsed from impossible times' do
    it 'raises an exception' do
      expect {
        described_class.parse('9900-2460')
      }.to raise_exception(described_class::ParseError)
    end
  end

  context 'when initialized with an end before the start' do
    it 'raises an exception' do
      expect {
        described_class.new(12, 00, 11, 10)
      }.to raise_exception(described_class::InvalidRange)
    end
  end
end
