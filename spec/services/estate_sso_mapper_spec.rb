require 'rails_helper'

RSpec.describe EstateSSOMapper do
  let(:instance) { described_class.new(orgs) }

  let!(:other_estate) { create(:estate) }

  context '#accessible_estates' do
    subject { instance.accessible_estates }

    context 'for apvu' do
      let!(:brinsford) do
        create(:estate, sso_organisation_name: 'brinsford.prisons.noms.moj')
      end
      let(:orgs) { ['apvu.noms.moj'] }

      it 'includes apvu estates' do
        is_expected.to include(brinsford)
        is_expected.to_not include(other_estate)
      end
    end

    context 'for sheppey cluster' do
      let!(:elmley) do
        create(:estate, sso_organisation_name: 'elmley.prisons.noms.moj')
      end
      let(:orgs) { ['sheppey_cluster.noms.moj'] }

      it 'includes sheppey cluster estates' do
        is_expected.to include(elmley)
        is_expected.to_not include(other_estate)
      end
    end

    context 'for grendon and springhill' do
      let!(:grendon) do
        create(:estate, sso_organisation_name: 'grendon.prisons.noms.moj')
      end
      let(:orgs) { ['grendon_and_springhill.noms.moj'] }

      it 'includes grendon and spring hill estates' do
        is_expected.to include(grendon)
        is_expected.to_not include(other_estate)
      end
    end

    context 'for isle of wight' do
      let!(:iow_parkhurst) do
        create(:estate,
          sso_organisation_name: 'isle_of_wight-parkhurst.prisons.noms.moj')
      end
      let(:orgs) { ['isle_of_wight.noms.moj'] }

      it 'includes isle of wight estates' do
        is_expected.to include(iow_parkhurst)
        is_expected.to_not include(other_estate)
      end
    end

    context 'combining orgs' do
      let(:estate1) { create(:estate) }
      let(:estate2) { create(:estate) }
      let(:orgs) { [estate1.sso_organisation_name, estate2.sso_organisation_name] }

      it 'includes the combined orgs' do
        is_expected.to contain_exactly(estate1, estate2)
        is_expected.to_not include(other_estate)
      end
    end

    context 'when the admin org' do
      let(:orgs) { ['digital.noms.moj'] }

      it 'includes all estates' do
        is_expected.to eq([other_estate])
      end
    end
  end
end
