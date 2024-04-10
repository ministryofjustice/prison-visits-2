require 'rails_helper'

RSpec.describe VsipSupportedPrisons do
  subject { described_class.instance }

  # Ensure that we have a new instance to prevent other specs interfering
  around do |ex|
    Singleton.__init__(described_class)
    ex.run
    Singleton.__init__(described_class)
  end

  context 'initialize' do
    context 'when vsip host set' do
      before do
        allow(Vsip::Api).to receive(:enabled?).and_return(true)
        allow_any_instance_of(Vsip::Api).to receive(:supported_prisons)
      end

      it 'when vsip host set' do
        expect(described_class.new.supported_prisons).to eq(nil)
      end
    end

    context 'when vsip host not set' do
      before do
        allow(Vsip::Api).to receive(:enabled?).and_return(false)
        # allow_any_isntance_of(Vsip::NullPrisoner).to receive(:initialize)
      end

      it 'when vsip host set' do
        expect(described_class.new.supported_prisons).to be_an_instance_of(Vsip::NullSupportedPrisons)
      end
    end
  end
end
