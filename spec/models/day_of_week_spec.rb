RSpec.describe DayOfWeek do
  describe 'by_name' do
    it 'finds a day by short name' do
      expect(described_class.by_name('mon')).to eq(described_class::MON)
      expect(described_class.by_name('sun')).to eq(described_class::SUN)
    end

    it 'raises an exception when the day does not exist' do
      expect {
        described_class.by_name('xxx')
      }.to raise_exception(described_class::NoSuchDay)
    end
  end

  it 'finds a day by index' do
    expect(described_class.by_index(0)).to eq(described_class::SUN)
    expect(described_class.by_index(1)).to eq(described_class::MON)
  end

  it 'has a name for each day' do
    expect(described_class::THU.name).to eq('thu')
  end

  it 'has an index for each day' do
    expect(described_class::THU.index).to eq(4)
  end

  it 'prevents initialisation' do
    expect {
      described_class.new('mon', 1)
    }.to raise_exception(ArgumentError)
  end
end
