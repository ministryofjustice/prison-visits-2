require 'spec_helper'
require 'date_coercer'

RSpec.describe DateCoercer do
  describe '.coerce' do
    context 'with nil' do
      it { expect(described_class.coerce(nil)).to be nil  }
    end
  end
end
