RSpec.shared_examples '.new' do |klass|
  describe '.new' do
    context "when the values are not all #{klass.name} " do
      let(:arg) { [klass.new, 'foo'] }

      it { expect { described_class.new(arg) }.to raise_error(ArgumentError) }
    end

    context "when the values are all #{klass.name} " do
      let(:arg) { [klass.new] }

      it { expect { described_class.new(arg) }.not_to raise_error }
    end
  end
end
