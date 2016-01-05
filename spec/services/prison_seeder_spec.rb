require 'rails_helper'

RSpec.describe PrisonSeeder do
  context 'importing from disk' do
    let(:base_path) { Rails.root.join('spec', 'fixtures', 'seeds') }

    it 'imports data from the YAML files' do
      expect {
        described_class.seed!(base_path)
      }.to change(Prison, :count).by(2)
    end

    it 'imports using the UUID mapping' do
      described_class.seed!(base_path)
      expect(Prison.find('67d22c66-41ac-431b-b24a-51bafb30ef8d')).
        to have_attributes(name: 'Lunar Penal Colony')
    end
  end

  context 'importing when the UUID is not mapped' do
    let(:filename_to_uuid_map) { {} }
    subject { described_class.new(filename_to_uuid_map) }

    it 'raises an exception on import' do
      expect {
        subject.import 'LNX-luna.yml', {}
      }.to raise_exception(PrisonSeeder::ImportFailure)
    end
  end

  context 'import' do
    subject { described_class.new(filename_to_uuid_map) }
    let(:filename) { 'LNX-luna.yml' }
    let(:uuid) { '0ff01907-42f6-4646-9bda-841ec27d4fc6' }
    let(:filename_to_uuid_map) { { filename => uuid } }
    let(:hash) {
      {
        'name' => 'Lunar Penal Colony',
        'nomis_id' => 'LNX',
        'address' => ['Outer Rim', 'Eratosthenes', 'Mare Imbrium', 'Luna'],
        'booking_window' => 28,
        'email' => 'luna@hmps.gsi.gov.uk',
        'enabled' => true,
        'estate' => 'Luna',
        'phone' => '0115 4960123',
        'slot_anomalies' => {
          Date.new(2015, 5, 25) => ['1330-1430'],
          Date.new(2015, 8, 31) => ['1330-1430']
        },
        'slots' => {
          'mon' => ['1330-1430'],
          'tue' => ['1330-1430']
        },
        'unbookable' => [Date.new(2015, 11, 4)]
      }
    }

    it 'creates a new record' do
      expect {
        subject.import filename, hash
      }.to change(Prison, :count).by(1)
    end

    it 'updates an existing record' do
      create :prison, id: uuid
      expect {
        subject.import filename, hash
      }.not_to change(Prison, :count)
      expect(Prison.find(uuid).name).to eq('Lunar Penal Colony')
    end

    it 'transforms slot details' do
      subject.import filename, hash
      expect(Prison.find(uuid).slot_details).to eq(
        "recurring" => {
          "mon" => ["1330-1430"],
          "tue" => ["1330-1430"]
        },
        "anomalous" => {
          "2015-05-25" => ["1330-1430"],
          "2015-08-31" => ["1330-1430"]
        },
        "unbookable" => ["2015-11-04"]
      )
    end

    it 'generates a default prison finder slug' do
      subject.import filename, hash
      expect(Prison.find(uuid).finder_slug).to eq('lunar-penal-colony')
    end

    it 'uses the supplied prison finder slug' do
      subject.import filename, hash.merge('finder_slug' => 'luna')
      expect(Prison.find(uuid).finder_slug).to eq('luna')
    end
  end
end
