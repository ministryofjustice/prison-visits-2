RSpec.describe ConcreteSlot do
  it 'parses from an ISO 8601 representation' do
    expected = described_class.new(2015, 10, 23, 14, 0, 15, 30)
    expect(described_class.parse('2015-10-23T14:00/15:30')).to eq(expected)
  end

  it 'raises an ArgumentError if parsing fails' do
    expect {
      described_class.parse('JUNK')
    }.to raise_exception(ArgumentError)
  end

  it 'generates an ISO 8601 representation' do
    subject = described_class.new(2015, 10, 23, 14, 0, 15, 30)
    expect(subject.iso8601).to eq('2015-10-23T14:00/15:30')
  end
end
