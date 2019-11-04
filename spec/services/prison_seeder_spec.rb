require 'rails_helper'

RSpec.describe PrisonSeeder do
  let(:filename) { 'LNX-luna.yml' }
  let(:uuid) { '0ff01907-42f6-4646-9bda-841ec27d4fc6' }
  let(:next_monday) { Time.zone.today - Time.zone.today.cwday.days + 8.days }
  let(:monday_week) { next_monday + 7.days }
  let(:hash) {
    {
      'name' => 'Lunar Penal Colony',
      'nomis_id' => 'LNX',
      'address' => "Outer Rim\nEratosthenes\nMare Imbrium\nLuna",
      'booking_window' => 28,
      'email_address' => 'luna@hmps.gsi.gov.uk',
      'postcode' => 'XL1 1AA',
      'enabled' => true,
      'closed' => false,
      'private' => false,
      'phone_no' => '0115 4960123',
      'translations' => {
        'cy' => {
          'name' => 'Lünar Penäl Colöny',
          'address' => "Oüter Rïm\nEratösthenes\nMäre Imbrïum\nLüna"
        }
      },
      'anomalous' => {
        Date.new(2015, 5, 25) => ['1330-1430'],
        Date.new(2015, 8, 31) => ['1330-1430']
      },
      'recurring' => {
        'mon' => ['1330-1430'],
        'tue' => ['1330-1430']
      },
      'unbookable' => [monday_week]
    }
  }

  context 'when importing from disk' do
    before do
      create :estate, nomis_id: 'LNX'
      create :estate, nomis_id: 'MRX'
    end

    let(:base_path) { Rails.root.join('spec', 'fixtures', 'seeds') }

    it 'imports prisons from the YAML files' do
      expect {
        described_class.seed! base_path
      }.to change(Prison, :count).by(2)
    end

    it 'imports using the UUID mapping' do
      described_class.seed! base_path
      expect(Prison.find('67d22c66-41ac-431b-b24a-51bafb30ef8d')).
        to have_attributes(name: 'Lunar Penal Colony')
    end
  end

  context 'when importing and the UUID is not mapped' do
    before do
      create :estate, nomis_id: 'LNX'
    end

    let(:filename_to_uuid_map) { {} }

    subject { described_class.new(Rails.logger, filename_to_uuid_map) }

    it 'raises an exception on import' do
      expect {
        subject.import 'LNX-luna.yml', hash
      }.to raise_exception(PrisonSeeder::ImportFailure)
    end
  end

  context 'with a successful import' do
    before do
      create :estate, nomis_id: 'LNX'
    end

    let(:filename_to_uuid_map) { { filename => uuid } }

    subject { described_class.new(Rails.logger, filename_to_uuid_map) }

    context 'when there is no existing record' do
      it 'creates a new prison record' do
        expect {
          subject.import filename, hash
        }.to change(Prison, :count).by(1)
      end

      it 'is associated with the estate record' do
        create :estate, name: 'Luna'
        subject.import filename, hash
        expect(Prison.find(uuid).estate.nomis_id).to eq('LNX')
      end

      it 'transforms slot details' do
        subject.import filename, hash
        prison = Prison.find(uuid)
        expect(prison.slot_details).to eq(
          "anomalous" => {
            "2015-05-25" => ["1330-1430"],
            "2015-08-31" => ["1330-1430"]
          }
        )
        expect(prison.unbookable_dates.map(&:date)).to eq([monday_week])
        expect(prison.recurring_slots).
          to eq(DayOfWeek::MON => [RecurringSlot.new(13, 30, 14, 30)],
                DayOfWeek::TUE => [RecurringSlot.new(13, 30, 14, 30)])
      end

      it 'imports translations' do
        subject.import filename, hash
        expect(Prison.find(uuid).translations).to eq(
          'cy' => {
            'name' => 'Lünar Penäl Colöny',
            'address' => "Oüter Rïm\nEratösthenes\nMäre Imbrïum\nLüna"
          }
        )
      end

      it 'uses the supplied email address' do
        subject.import filename, hash
        expect(Prison.find(uuid)).
          to have_attributes(email_address: 'luna@hmps.gsi.gov.uk')
      end
    end

    context 'with an existing record' do
      let(:next_tuesday) { next_monday + 1.day }

      before {
        prison = create :prison_with_slots, id: uuid
        create(:unbookable_date, prison: prison, date: next_monday)
        create(:unbookable_date, prison: prison, date: next_tuesday)
      }

      it 'updates an existing prison record' do
        expect {
          subject.import filename, hash
        }.not_to change(Prison, :count)
        prison = Prison.find(uuid)
        expect(prison.name).to eq('Lunar Penal Colony')
        expect(prison.unbookable_dates.map(&:date)).to eq([next_monday, next_tuesday, monday_week])
      end
    end
  end
end
