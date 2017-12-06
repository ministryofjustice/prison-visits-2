require 'rails_helper'

RSpec.describe AdminMailer do
  describe '#slot_availability' do
    let(:availability) do
      {
        'Pentonville' => {
          visits_checked: 90,
          bad_range: 1,
          hard_failures: 1,
          retries: 1,
          unavailable_visits: 25
        },
        'Leeds' => {
          visits_checked: 50,
          bad_range: 2,
          hard_failures: 4,
          retries: 6,
          unavailable_visits: 20
        }
      }
    end

    let(:mail) { described_class.slot_availability(availability) }
    let(:email_address) { 'user@example.com' }

    before do
      ActionMailer::Base.deliveries.clear
      set_configuration_with(:pvb_team_email, email_address)
    end

    around do |example|
      travel_to Date.parse('2017-06-27') do
        example.call
      end
    end

    it { expect(mail.to).to include(email_address) }

    it 'sets the subject' do
      expect(mail.subject).to eq('Slot availability - 2017-06-27')
    end

    it "includes information from the prisons" do
      expect(mail.html_part.body).to match(/Pentonville/)
      expect(mail.html_part.body).to match(/Leeds/)
      expect(mail.html_part.body).to match(/visits_checked: 90/)
      expect(mail.html_part.body).to match(/visits_checked: 50/)
    end
  end

  describe '#confirmed_bookings' do
    let(:email_address) { 'john@example.com' }
    let(:mail) { described_class.confirmed_bookings(email_address) }
    let(:csv) { 'a,b,c' }
    let(:exporter) { double(to_csv: csv) }

    before do
      expect(WeeklyMetricsConfirmedCsvExporter).
        to receive(:new).
        and_return(exporter)
    end

    it { expect(mail.to).to include(email_address) }
    it { expect(mail.subject).to eq('Confirmed bookings (CSV)') }

    it 'includes a csv attachment with the data' do
      expect(mail.attachments).
        to satisfy('include the csv attachment') do |attachments|
        attachments.any? do |attachment|
          attachment.filename == 'confirmed_bookings.csv' &&
            attachment.body == csv
        end
      end
    end
  end
end
