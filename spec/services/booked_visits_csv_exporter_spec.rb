require 'rails_helper'

RSpec.describe BookedVisitsCsvExporter do
  let(:prison) { FactoryBot.create(:prison_with_slots) }
  let(:estates) { [prison.estate] }

  let!(:booked_visit) do
    FactoryBot.create(:booked_visit, prison: prison)
  end
  let!(:cancelled_visit) do
    FactoryBot.create(:cancelled_visit, prison: prison)
  end
  let!(:second_visitor) do
    FactoryBot.create(:visitor, visit: booked_visit, not_on_list: true)
  end
  let!(:third_visitor) do
    FactoryBot.create(:visitor, visit: booked_visit, banned: true)
  end
  let!(:fourth_visitor) do
    FactoryBot.create(:visitor, visit: booked_visit)
  end

  let(:visit_date) { booked_visit.slot_granted.to_date }
  let(:data) do
    EstateVisitQuery.new(estates).visits_to_print_by_slot(visit_date)
  end
  let(:instance) { described_class.new(data) }

  describe '#to_csv' do
    subject(:csv) do
      CSV.parse(instance.to_csv).map { |r| Hash[instance.headers.zip(r)] }
    end

    it { expect(csv.size).to eq(3) }

    it 'contains the headers' do
      expect(csv[0].keys).to eq(instance.headers)
    end

    it 'serialises the booked and cancelled visits' do
      row = csv.find { |r| r['Status'] == 'cancelled' }
      expect(row['Status']).to eq(cancelled_visit.processing_state)

      row = csv.find { |r| r['Status'] == 'booked' }
      expect(row['Status']).to eq(booked_visit.processing_state)
      expect(row['Prison']).to eq(booked_visit.prison_name)
      expect(row['Prisoner name']).to eq(booked_visit.prisoner_full_name)
      expect(row['Prisoner number']).to eq(booked_visit.prisoner_number)
      expect(row['Slot granted']).
        to eq(instance.format_slot_for_staff(booked_visit.slot_granted))
      expect(row['Closed visit']).to eq('false')

      expect(row['Phone number']).to eq(booked_visit.contact_phone_no)
      expect(row['Email address']).to eq(booked_visit.contact_email_address)

      expect(row['Lead visitor']).to eq(booked_visit.visitor_full_name)
      expect(row['Lead visitor dob']).
        to eq(booked_visit.visitor_date_of_birth.to_s)
      expect(row['Lead visitor allowed?']).to eq('true')

      expect(row['Visitor 2 name']).to eq(second_visitor.full_name)
      expect(row['Visitor 2 dob']).to eq(second_visitor.date_of_birth.to_s)
      expect(row['Visitor 2 allowed?']).to eq('false')

      expect(row['Visitor 3 name']).to eq(third_visitor.full_name)
      expect(row['Visitor 3 dob']).to eq(third_visitor.date_of_birth.to_s)
      expect(row['Visitor 3 allowed?']).to eq('false')

      expect(row['Visitor 4 name']).to eq(fourth_visitor.full_name)
      expect(row['Visitor 4 dob']).to eq(fourth_visitor.date_of_birth.to_s)
      expect(row['Visitor 4 allowed?']).to eq('true')

      expect(row['Visitor 5 name']).to be_nil
      expect(row['Visitor 5 name']).to be_nil
      expect(row['Visitor 5 dob']).to be_nil

      expect(row['Visitor 6 allowed?']).to be_nil
      expect(row['Visitor 6 dob']).to be_nil
      expect(row['Visitor 6 allowed?']).to be_nil
    end
  end
end
