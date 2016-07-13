require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.from_sso' do
    subject(:from_sso) { described_class.from_sso(attrs) }

    let(:attrs) do
      {
        'email' => FFaker::Internet.email,
        'permissions' => permissions
      }
    end

    context 'has already a PVB record' do
      let(:permissions) { anything }

      let!(:user) { FactoryGirl.create(:user, email: attrs['email']) }

      it { is_expected.to eq(user) }
    end

    context "hasn't got a PVB record" do
      describe 'with the right permissions' do
        let(:org_name) { 'cardiff.noms' }
        let!(:estate) do
          FactoryGirl.create(:estate, sso_organisation_name: org_name)
        end
        let(:permissions) do
          [{ 'organisation' => org_name, 'roles' => [anything] }]
        end

        it 'creates a user associated to the correct estate' do
          expect { from_sso }.
            to change {
              described_class.
                where(email: attrs['email'], estate_id: estate.id).
                count
            }.by(1)
        end
      end

      describe 'with no permissions for PVB' do
        let(:permissions) { [] }

        it { is_expected.to be_nil }
      end

      describe 'with permissions to an unknown organisation' do
        let(:permissions) do
          [{ 'organisation' => 'random', 'roles' => [anything] }]
        end

        it { is_expected.to be_nil }
      end
    end
  end
end
