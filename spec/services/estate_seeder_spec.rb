require 'rails_helper'

RSpec.describe EstateSeeder do
  context 'when importing from disk' do
    let(:base_path) { Rails.root.join('spec', 'fixtures', 'seeds') }

    it 'creates estates' do
      expect {
        described_class.seed! base_path
      }.to change(Estate, :count).by(2)
    end
  end

  context 'with a successful import' do
    let(:nomis_id) { 'LNX' }
    let(:hash) { { 'name' => 'Lunar Penal Colony' } }

    it 'creates a new estate record' do
      expect {
        subject.import nomis_id, hash
      }.to change(Estate, :count).by(1)
    end

    it 'generates a default prison finder slug' do
      subject.import nomis_id, hash
      expect(Estate.find_by(nomis_id:))
        .to have_attributes(finder_slug: 'lunar-penal-colony')
    end

    it 'uses the supplied prison finder slug' do
      subject.import nomis_id, hash.merge('finder_slug' => 'luna')
      expect(Estate.find_by(nomis_id:))
        .to have_attributes(finder_slug: 'luna')
    end

    it 'generates a default for admins' do
      subject.import nomis_id, hash
      expect(Estate.find_by(nomis_id:).admins).to be_empty
    end

    it 'uses the supplied admins' do
      subject.import nomis_id, hash.merge('admins' => ['apvu.noms.moj'])
      expect(Estate.find_by(nomis_id:))
        .to have_attributes(admins: ['apvu.noms.moj'])
    end

    it 'generates an sso organisation name' do
      subject.import nomis_id, hash.merge('name' => 'Lunar Penal Colony - A')
      expect(Estate.find_by(nomis_id:)).to have_attributes(
        sso_organisation_name: 'lunar_penal_colony-a.prisons.noms.moj'
      )
    end
  end
end
