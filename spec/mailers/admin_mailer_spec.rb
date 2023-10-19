require 'rails_helper'

RSpec.describe AdminMailer do
  describe '#confirmed_bookings' do
    let(:email_address) { 'john@example.com' }
    let(:mail) { described_class.confirmed_bookings(email_address) }
    let(:csv) { 'a,b,c' }
    let(:exporter) { double(to_csv: csv) }

    before do
      expect(WeeklyMetricsConfirmedCsvExporter)
        .to receive(:new)
        .and_return(exporter)
    end

    it { expect(mail.to).to include(email_address) }
    it { expect(mail.subject).to eq('Confirmed bookings (CSV)') }

    it 'includes a csv attachment with the data' do
      expect(mail.attachments)
        .to satisfy('include the csv attachment') do |attachments|
        attachments.any? do |attachment|
          attachment.filename == 'confirmed_bookings.csv' &&
            attachment.body == csv
        end
      end
    end
  end
end
