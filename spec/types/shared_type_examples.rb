RSpec.shared_examples 'type' do |klass|
  it "returns an array of #{klass} types" do
    casted = subject.cast(value)
    expect(casted).to all(be_an(klass))
    expect(casted.count).to be(value.size)
  end
end
