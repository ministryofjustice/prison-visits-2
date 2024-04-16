require 'rails_helper'

RSpec.describe VsipVisitSessions do
  subject { described_class }

  context 'when seswsions received' do
    before do
      allow(Vsip::Api).to receive(:enabled?).and_return(true)
      allow_any_instance_of(Vsip::Api).to receive(:visit_sessions).and_return(:sessions)
    end

    it 'retrieves VSiP sessions' do
      expect(subject.get_sessions(1, 1)).to eq(:sessions)
    end
  end

  context 'when there is an api error' do
    before do
      allow(Vsip::Api).to receive(:enabled?).and_return(false)
      allow_any_instance_of(Vsip::Api).to receive(:visit_sessions).and_return(:sessions)
    end

    it 'retrieves VSiP sessions' do
      expect(subject.get_sessions(1, 1)).to be_an_instance_of(Vsip::NullSupportedPrisons)
    end
  end
end
