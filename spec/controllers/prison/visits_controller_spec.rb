require 'rails_helper'
require_relative '../untrusted_examples'

RSpec.describe Prison::VisitsController, type: :controller do
  let(:visit) { create(:visit) }

  describe '#update' do
    subject do
      put :update,
        id: visit.id,
        booking_response: booking_response,
        locale: 'en'
    end

    let(:booking_response) { { selection: 'slot_0' } }

    it_behaves_like 'disallows untrusted ips'

    context 'when invalid' do
      it { is_expected.to render_template('process_visit') }
    end

    context 'when valid' do
      let(:booking_response) { { selection: 'slot_0', reference_no: 'none' } }

      it { is_expected.to redirect_to(prison_deprecated_visit_path(visit)) }
    end
  end

  describe '#show' do
    subject { get :show, id: visit.id }

    it { is_expected.to render_template('show') }

    it_behaves_like 'disallows untrusted ips'
  end
end
