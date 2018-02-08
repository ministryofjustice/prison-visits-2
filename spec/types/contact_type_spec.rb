require 'rails_helper'

RSpec.describe ContactType do
  subject { described_class.new }

  describe '#cast' do
    let(:casted) { Nomis::Contact.new(given_name: 'John') }

    context 'with a Hash' do
      let(:value) { { given_name: 'John' } }

      it { expect(subject.cast(value)).to eq(casted) }
    end

    context 'with a Contact' do
      it { expect(subject.cast(casted)).to eq(casted) }
    end
  end
end
