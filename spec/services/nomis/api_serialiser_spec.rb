require 'rails_helper'

RSpec.describe Nomis::ApiSerialiser do
  let!(:memory_model_class) do
    Class.new do
      include MemoryModel
      attribute :foo, :string
    end
  end

  let(:payload) do
    { foo: :bar, unknown_attribute: :boom }
  end

  subject { model.new(payload) }

  it 'serialises a payload with unknown attributes', :expect_exception do
    expect(described_class.new.serialise(memory_model_class, payload)).to have_attributes foo: 'bar'
  end

  it 'raises an error in dev or tests mode' do
    expect {
      described_class.new.serialise(memory_model_class, payload)
    }.to raise_error(Nomis::Error::UnhandledApiField)
  end
end
