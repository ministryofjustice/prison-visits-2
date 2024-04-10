require 'rails_helper'

class DummyEstate
  def update _
  end
end

RSpec.describe Vsip::Api do
  subject { described_class.instance }

  # Ensure that we have a new instance to prevent other specs interfering
  around do |ex|
    Singleton.__init__(described_class)
    ex.run
    Singleton.__init__(described_class)
  end

  it 'is implicitly enabled if the api host is configured' do
    expect(Rails.configuration).to receive(:vsip_host).and_return(nil)
    expect(described_class.enabled?).to be false

    expect(Rails.configuration).to receive(:vsip_host).and_return('http://example.com/')
    expect(described_class.enabled?).to be true
  end

  it 'fails if code attempts to use the client when disabled' do
    expect(described_class).to receive(:enabled?).and_return(false)
    expect {
      described_class.instance
    }.to raise_error(Vsip::Error::Disabled, 'Vsip API is disabled')
  end

  describe 'initialize' do
    it 'initializes' do
      expect(described_class).to eq(Vsip::Api)
    end
  end

  describe 'supported_prisons' do
    context 'gets list back from api'
      let(:estate) {  create(:estate, nomis_id: 'LEI') }

      before do
        allow(Estate).to receive(:where).and_return(DummyEstate.new)
        allow_any_instance_of(Vsip::Client).to receive(:get).and_return(%w[LEI])
      end

      it 'returns list of supported prisons' do
        expect(Vsip::Api.instance.supported_prisons).to eq(["LEI"])
      end
  end
  context 'no list back from api' do
    context 'gets list back from api'

    before do
      allow_any_instance_of(Vsip::Client).to receive(:get).and_raise(Vsip::APIError)
      # allow_any_instance_of(Vsip::Client).to receive(:get).and_return(:return_val)
    end

    it 'returns list of supported prisons' do
      expect { Vsip::Api.instance.supported_prisons }.to raise_error(Vsip::APIError)
      # expect(Vsip::Api.instance.supported_prisons).to_not be_success
    end

  end
end
