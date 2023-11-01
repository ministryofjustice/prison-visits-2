require 'spec_helper'

RSpec.describe Healthcheck::SmtpCheck do
  subject {
    described_class.new('SMTP connection', smtp_settings: smtp_settings)
  }

  let(:smtp_settings) { { address: 'smtp.example.com', port: 587 } }

  it 'connects to the specified host and port' do
    expect(Net::SMTP).to receive(:start).with('smtp.example.com', 587)
    subject.report
  end

  context 'when it connects' do
    let(:smtp) { double(enable_starttls_auto: nil, ehlo: nil, finish: nil) }

    before do
      allow(Net::SMTP).to receive(:start).and_yield(smtp)
    end

    it { is_expected.to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'SMTP connection',
        ok: true
      )
    end
  end

  context 'when it times out' do
    before do
      allow(Net::SMTP).to receive(:start)
        .and_raise(Net::OpenTimeout, 'timed out')
    end

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'SMTP connection',
        ok: false,
        error: 'timed out'
      )
    end
  end

  context 'when the port is closed' do
    before do
      allow(Net::SMTP).to receive(:start)
        .and_raise(Errno::ECONNREFUSED, 'port closed')
    end

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'SMTP connection',
        ok: false,
        error: 'Connection refused - port closed'
      )
    end
  end

  context 'when the hostname cannot be resolved' do
    before do
      allow(Net::SMTP).to receive(:start)
        .and_raise(SocketError, 'hostname not resolved')
    end

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'SMTP connection',
        ok: false,
        error: 'hostname not resolved'
      )
    end
  end
end
