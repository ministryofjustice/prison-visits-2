require 'rails_helper'

RSpec.describe Healthcheck do
  let(:database_check) {
    instance_double(Healthcheck::DatabaseCheck, ok?: database_ok, report: database_report)
  }
  # let(:zendesk_check) {
  #   instance_double(Healthcheck::QueueCheck, ok?: zendesk_ok, report: zendesk_report)
  # }
  # let(:mailers_check) {
  #   instance_double(Healthcheck::QueueCheck, ok?: mailers_ok, report: mailers_report)
  # }
  # let(:smtp_check) {
  #   instance_double(Healthcheck::SmtpCheck, ok?: smtp_ok, report: smtp_report)
  # }

  let(:database_report) { { description: 'database', ok: database_ok } }
  # let(:zendesk_report) { { description: 'zendesk', ok: zendesk_ok } }
  # let(:mailers_report) { { description: 'mailers', ok: mailers_ok } }
  # let(:smtp_report) { { description: 'smtp', ok: smtp_ok } }

  before do
    allow(Healthcheck::DatabaseCheck).to receive(:new).
      and_return(database_check)
    # allow(Healthcheck::QueueCheck).to receive(:new).
    #   with(anything, queue_name: 'zendesk').and_return(zendesk_check)
    # allow(Healthcheck::QueueCheck).to receive(:new).
    #   with(anything, queue_name: 'mailers').and_return(mailers_check)
    # allow(Healthcheck::SmtpCheck).to receive(:new).
    #   and_return(smtp_check)
  end

  context 'when everything is OK' do
    let(:database_ok) { true }
    # let(:zendesk_ok) { true }
    # let(:mailers_ok) { true }
    # let(:smtp_ok) { true }

    it { is_expected.to be_ok }

    it 'combines the reports' do
      expect(subject.checks).to eq(
        ok: true,
        # zendesk: zendesk_report,
        # mailers: mailers_report,
        database: database_report
        # smtp: smtp_report
      )
    end
  end

  context 'when there is a problem' do
    let(:database_ok) { false }
    # let(:zendesk_ok) { true }
    # let(:mailers_ok) { true }
    # let(:smtp_ok) { true }

    it { is_expected.not_to be_ok }

    it 'combines the reports' do
      expect(subject.checks).to eq(
        ok: false,
        # zendesk: zendesk_report,
        # mailers: mailers_report,
        database: database_report
        # smtp: smtp_report
      )
    end
  end
end
