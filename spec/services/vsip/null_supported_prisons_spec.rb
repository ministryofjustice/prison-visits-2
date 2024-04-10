require 'rails_helper'

RSpec.describe Vsip::NullSupportedPrisons do
  # Ensure that we have a new instance to prevent other specs interfering
  around do |ex|
    Singleton.__init__(described_class)
    ex.run
    Singleton.__init__(described_class)
  end

  context 'valid?' do
    it 'valid?' do
      expect(described_class.new.valid?).to be_falsey
    end
  end

  # context 'iep_level' do
  #   it 'iep_level' do
  #     expect(described_class.new.iep_level)
  #   end
  # end

  context 'api_call_successful?' do
    let(:null_supported_prisons) { described_class.new }

    it 'returns whether the api was successfully called' do
      null_supported_prisons.api_call_successful = false

      expect(null_supported_prisons.api_call_successful?).to be_falsey
    end
  end
end
