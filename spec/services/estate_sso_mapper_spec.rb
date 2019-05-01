require 'rails_helper'

RSpec.describe EstateSSOMapper do
  let(:instance) { described_class.new(user_sso_orgs) }

  let!(:other_estate) do
    create(:estate,
           sso_organisation_name: 'other_estate.prisons.noms.moj',
           admins: ['other_estate.prisons.noms.moj'])
  end

  around(:each) do |ex|
    described_class.reset_grouped_estates
    ex.run
    described_class.reset_grouped_estates
  end

  describe '.grouped_estates' do
    subject { described_class.grouped_estates }

    let!(:brinsford) do
      create(:estate,
             sso_organisation_name: 'brinsford.prisons.noms.moj',
             admins: ['apvu.noms.moj', 'brinsford.prisons.noms.moj'])
    end

    it {
      expect(subject).to eq('apvu.noms.moj' => ['brinsford.prisons.noms.moj'],
                            'brinsford.prisons.noms.moj' => ['brinsford.prisons.noms.moj'],
                            'other_estate.prisons.noms.moj' => ['other_estate.prisons.noms.moj'])
    }
  end

  describe '#accessible_estates' do
    subject { instance.accessible_estates }

    context 'when for Brinsford only' do
      let!(:brinsford) do
        create(:estate,
               sso_organisation_name: 'brinsford.prisons.noms.moj',
               admins: ['brinsford.prisons.noms.moj'])
      end
      let(:user_sso_orgs) { ['brinsford.prisons.noms.moj'] }

      it 'includes Brinsford estates' do
        expect(subject).to include(brinsford)
        expect(subject).not_to include(other_estate)
      end
    end

    context 'when for apvu only' do
      let!(:brinsford) do
        create(:estate,
               sso_organisation_name: 'brinsford.prisons.noms.moj',
               admins: ['apvu.noms.moj'])
      end
      let(:user_sso_orgs) { ['apvu.noms.moj'] }

      it 'includes apvu estates' do
        expect(subject).to include(brinsford)
        expect(subject).not_to include(other_estate)
      end
    end

    context 'when for grendon and springhill' do
      let!(:grendon) do
        create(:estate,
               sso_organisation_name: 'grendon.prisons.noms.moj',
               admins: ['grendon_and_springhill.noms.moj'])
      end
      let(:user_sso_orgs) { ['grendon_and_springhill.noms.moj'] }

      it 'includes grendon and spring hill estates' do
        expect(subject).to include(grendon)
        expect(subject).not_to include(other_estate)
      end
    end

    context 'when for isle of wight' do
      let!(:iow_parkhurst) do
        create(:estate,
               sso_organisation_name: 'isle_of_wight-parkhurst.prisons.noms.moj',
               admins: ['isle_of_wight.noms.moj'])
      end
      let(:user_sso_orgs) { ['isle_of_wight.noms.moj'] }

      it 'includes isle of wight estates' do
        expect(subject).to include(iow_parkhurst)
        expect(subject).not_to include(other_estate)
      end
    end

    context 'when combining orgs' do
      let!(:wandsworth) do
        create(:estate,
               sso_organisation_name: 'wandsworth.prisons.noms.moj',
               admins: ['wandsworth.prisons.noms.moj'])
      end

      let!(:brixton) do
        create(:estate,
               sso_organisation_name: 'brixton.prisons.noms.moj',
               admins: ['brixton.prisons.noms.moj'])
      end
      let(:user_sso_orgs) { ['wandsworth.prisons.noms.moj', 'brixton.prisons.noms.moj'] }

      it 'includes the combined orgs' do
        expect(subject).to include(wandsworth, brixton)
        expect(subject).not_to include(other_estate)
      end
    end

    context 'when the admin org' do
      let(:user_sso_orgs) { ['digital.noms.moj'] }

      it 'includes all estates' do
        expect(subject).to eq([other_estate])
      end
    end

    context 'when a prison is spelt incorrectly' do
      let!(:full_sutton) do
        create(:estate,
               sso_organisation_name: 'full_sutton.prisons.noms.moj',
               admins: ['full_stutton.prison.noms.moj'])
      end
      let(:user_sso_orgs) { ['full_sutton.prisons.noms.moj'] }

      it { is_expected.to be_empty }
    end
  end
end
