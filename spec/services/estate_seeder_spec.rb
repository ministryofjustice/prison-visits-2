require 'rails_helper'

RSpec.describe EstateSeeder do
  context 'importing from disk' do
    let(:base_path) { Rails.root.join('spec', 'fixtures', 'seeds') }

    it 'creates estates' do
      expect {
        described_class.seed! base_path
      }.to change(Estate, :count).by(2)
    end
  end

  context 'successful import' do
    let(:nomis_id) { 'LNX' }
    let(:hash) { { 'name' => 'Lunar Penal Colony' } }

    it 'creates a new estate record' do
      expect {
        subject.import nomis_id, hash
      }.to change(Estate, :count).by(1)
    end

    it 'generates a default prison finder slug' do
      subject.import nomis_id, hash
      expect(Estate.find_by(nomis_id: nomis_id)).
        to have_attributes(finder_slug: 'lunar-penal-colony')
    end

    it 'uses the supplied prison finder slug' do
      subject.import nomis_id, hash.merge('finder_slug' => 'luna')
      expect(Estate.find_by(nomis_id: nomis_id)).
        to have_attributes(finder_slug: 'luna')
    end
  end
end
