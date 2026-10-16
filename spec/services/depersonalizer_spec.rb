require 'rails_helper'

RSpec.describe Depersonalizer do
  let(:cutoff_date) { Time.zone.now.change(usec: 0) - 6.months }

  shared_examples 'indexed anonymisation' do |factory, marker|
    let(:record) { create(factory, created_at: cutoff_date, updated_at: cutoff_date) }

    it 'does not anonymise records exactly at the cutoff date' do
      expect { subject.remove_personal_information(cutoff_date) }
        .not_to change { record.reload.attributes }
    end

    it 'preserves timestamps when anonymising eligible records' do
      record.update_columns(created_at: cutoff_date - 1.second)

      expect { subject.remove_personal_information(cutoff_date) }
        .not_to change { record.reload.updated_at }
    end

    it 'has a partial creation-date index matching the eligibility predicate' do
      index = record.class.connection.indexes(record.class.table_name).find { |definition|
        definition.name == "index_#{record.class.table_name}_pending_anonymisation"
      }

      expect(index).to have_attributes(
        columns: ['created_at'],
        unique: false,
        where: "((#{marker})::text <> 'REMOVED'::text)"
      )
    end
  end

  context 'with indexed prisoners' do
    include_examples 'indexed anonymisation', :prisoner, :first_name
  end

  context 'with indexed visitors' do
    include_examples 'indexed anonymisation', :visitor, :first_name
  end

  context 'with indexed visits' do
    include_examples 'indexed anonymisation', :visit, :contact_email_address
  end

  it 'does not carry visitor display ordering into the bulk update' do
    queries = []
    subscriber = ->(*arguments) { queries << arguments.last[:sql] }

    ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record') do
      subject.remove_personal_information(cutoff_date)
    end

    visitor_update = queries.find { |sql| sql.start_with?('UPDATE "visitors"') }
    expect(visitor_update).to be_present
    expect(visitor_update).not_to include('ORDER BY', 'SELECT')
  end

  context 'when processing prisoners' do
    let!(:prisoner) {
      create(
        :prisoner,
        first_name: 'Oscar',
        last_name: 'Wilde',
        date_of_birth: Date.new(1980, 1, 1),
        number: 'ABC1234'
      )
    }

    it 'anonymises prisoners older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(prisoner.reload).to have_attributes(
        first_name: 'REMOVED',
        last_name: 'REMOVED',
        date_of_birth: Date.new(1, 1, 1),
        number: 'REMOVED'
      )
    end

    it 'does not anonymise prisoners newer than the cutoff date' do
      subject.remove_personal_information(Time.zone.now - 1.day)
      expect(prisoner.reload).to have_attributes(
        first_name: 'Oscar',
        last_name: 'Wilde',
        date_of_birth: Date.new(1980, 1, 1),
        number: 'ABC1234'
      )
    end
  end

  context 'when processing visitors' do
    let!(:visitor) {
      create(
        :visitor,
        first_name: 'Ada',
        last_name: 'Lovelace',
        date_of_birth: Date.new(1970, 2, 3)
      )
    }

    it 'anonymises visitors older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(visitor.reload).to have_attributes(
        first_name: 'REMOVED',
        last_name: 'REMOVED',
        date_of_birth: Date.new(1, 1, 1)
      )
    end

    it 'does not anonymise visitors newer than the cutoff date' do
      subject.remove_personal_information(Time.zone.now - 1.day)
      expect(visitor.reload).to have_attributes(
        first_name: 'Ada',
        last_name: 'Lovelace',
        date_of_birth: Date.new(1970, 2, 3)
      )
    end
  end

  context 'when processing visits' do
    let!(:visit) {
      create(
        :visit,
        contact_email_address: 'user@example.com',
        contact_phone_no: '079 00112233'
      )
    }

    it 'anonymises visits older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(visit.reload).to have_attributes(
        contact_email_address: 'REMOVED',
        contact_phone_no: 'REMOVED'
      )
    end

    it 'does not anonymise visits newer than the cutoff date' do
      subject.remove_personal_information(Time.zone.now - 1.day)
      expect(visit.reload).to have_attributes(
        contact_email_address: 'user@example.com',
        contact_phone_no: '07900112233'
      )
    end
  end

  context 'when prisoner not already anonymised' do
    let!(:prisoner) {
      create(
        :prisoner,
        first_name: 'REMOVED',
        last_name: 'Wilde',
        date_of_birth: Date.new(1980, 1, 1),
        number: 'ABC1234'
      )
    }

    it 'does not anonymise prisoners older than the cutoff date, who have already been processed' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(prisoner.reload).to have_attributes(
        first_name: 'REMOVED',
        last_name: 'Wilde',
        date_of_birth: Date.new(1980, 1, 1),
        number: 'ABC1234'
      )
    end
  end

  context 'when visitor not already anonymised' do
    let!(:visitor) {
      create(
        :visitor,
        first_name: 'REMOVED',
        last_name: 'Lovelace',
        date_of_birth: Date.new(1970, 2, 3)
      )
    }

    it 'anonymises visitors older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(visitor.reload).to have_attributes(
        first_name: 'REMOVED',
        last_name: 'Lovelace',
        date_of_birth: Date.new(1970, 2, 3)
      )
    end
  end

  context 'when visit not already anonymised' do
    let!(:visit) {
      create(
        :visit,
        contact_email_address: 'REMOVED',
        contact_phone_no: '079 00112233'
      )
    }

    it 'anonymises visits older than the cutoff date' do
      subject.remove_personal_information(Time.zone.now + 1.day)
      expect(visit.reload).to have_attributes(
        contact_email_address: 'REMOVED',
        contact_phone_no: '07900112233'
      )
    end
  end
end
