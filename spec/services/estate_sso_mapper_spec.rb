require 'rails_helper'

RSpec.describe EstateSSOMapper do
  let(:instance) { described_class.new(orgs) }

  let!(:other_estate) { create(:estate) }

  around(:each) do |ex|
    described_class.instance_variable_set('@grouped_estates', nil)
    ex.run
    described_class.instance_variable_set('@grouped_estates', nil)
  end

  describe '#grouped_estates' do
    subject { described_class.grouped_estates }

    let!(:brinsford) do
      create(:estate,
        sso_organisation_name: 'brinsford.prisons.noms.moj',
        group: 'apvu.noms.moj')
    end

    it { is_expected.to eq('apvu.noms.moj' => ['brinsford.prisons.noms.moj']) }
  end

  describe '#accessible_estates' do
    subject { instance.accessible_estates }

    context 'for apvu' do
      let!(:brinsford) do
        create(:estate,
          sso_organisation_name: 'brinsford.prisons.noms.moj',
          group: 'apvu.noms.moj')
      end
      let(:orgs) { ['apvu.noms.moj'] }

      before do
        allow(described_class).
          to receive(:grouped_estates).
          and_return('apvu.noms.moj' => ['brinsford.prisons.noms.moj'])
      end

      it 'includes apvu estates' do
        is_expected.to include(brinsford)
        is_expected.to_not include(other_estate)
      end
    end

    context 'for sheppey cluster' do
      let!(:elmley) do
        create(:estate,
          sso_organisation_name: 'elmley.prisons.noms.moj',
          group: 'sheppey_cluster.noms.moj')
      end
      let(:orgs) { ['sheppey_cluster.noms.moj'] }

      before do
        allow(described_class).
          to receive(:grouped_estates).
          and_return('sheppey_cluster.noms.moj' => ['elmley.prisons.noms.moj'])
      end

      it 'includes sheppey cluster estates' do
        is_expected.to include(elmley)
        is_expected.to_not include(other_estate)
      end
    end

    context 'for grendon and springhill' do
      let!(:grendon) do
        create(:estate,
          sso_organisation_name: 'grendon.prisons.noms.moj',
          group: 'grendon_and_springhill.noms.moj')
      end
      let(:orgs) { ['grendon_and_springhill.noms.moj'] }

      before do
        allow(described_class).
          to receive(:grouped_estates).
          and_return('grendon_and_springhill.noms.moj' => ['grendon.prisons.noms.moj'])
      end

      it 'includes grendon and spring hill estates' do
        is_expected.to include(grendon)
        is_expected.to_not include(other_estate)
      end
    end

    context 'for isle of wight' do
      let!(:iow_parkhurst) do
        create(:estate,
          sso_organisation_name: 'isle_of_wight-parkhurst.prisons.noms.moj',
          group: 'isle_of_wight.noms.moj')
      end
      let(:orgs) { ['isle_of_wight.noms.moj'] }

      before do
        allow(described_class).
          to receive(:grouped_estates).
          and_return('isle_of_wight.noms.moj' => ['isle_of_wight-parkhurst.prisons.noms.moj'])
      end

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
