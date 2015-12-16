require 'spec_helper'

RSpec.describe IpAddressMatcher do
  it 'matches a single IP address' do
    matcher = described_class.new('12.34.56.78')
    expect(matcher).to include('12.34.56.78')
    expect(matcher).not_to include('11.22.33.44')
  end

  it 'matches several IP addresses separated by commas' do
    matcher = described_class.new('12.34.56.78,127.0.0.1,8.8.8.8')
    expect(matcher).to include('12.34.56.78')
    expect(matcher).to include('127.0.0.1')
    expect(matcher).to include('8.8.8.8')
    expect(matcher).not_to include('11.22.33.44')
  end

  it 'matches several IP addresses separated by semicolons' do
    matcher = described_class.new('12.34.56.78;8.8.8.8')
    expect(matcher).to include('12.34.56.78')
    expect(matcher).to include('8.8.8.8')
    expect(matcher).not_to include('11.22.33.44')
  end

  it 'matches CIDR ranges' do
    matcher = described_class.new('12.34.0.0/16,127.0.0.0/24')
    expect(matcher).to include('12.34.56.78')
    expect(matcher).to include('127.0.0.1')
    expect(matcher).not_to include('12.33.44.44')
  end
end
