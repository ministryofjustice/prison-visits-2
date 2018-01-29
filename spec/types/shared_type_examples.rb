RSpec.shared_examples 'enumerable type' do |klass|
  it "returns a #{klass}" do
    casted = subject.cast(value)
    expect(casted).to be_a(klass)
    expect(casted.count).to be(value.size)
  end
end
