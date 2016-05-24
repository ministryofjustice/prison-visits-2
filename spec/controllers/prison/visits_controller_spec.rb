require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) { create(:visit) }

  describe '#update' do
    subject do
      put :update,
        id: visit.id,
        booking_response: { selection: 'slot_0' },
        locale: 'en'
    end

    it { is_expected.to render_template('process_visit') }

    it_behaves_like 'disallows untrusted ips'
  end

  describe '#show' do
    subject { get :show, id: visit.id }

    it { is_expected.to render_template('show') }

    it_behaves_like 'disallows untrusted ips'
  end
end
