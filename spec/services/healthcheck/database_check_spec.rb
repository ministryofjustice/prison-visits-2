require 'rails_helper'

RSpec.describe Healthcheck::DatabaseCheck do
  subject { described_class.new('Database check') }

  context 'with a working connection' do
    before do
      allow(ActiveRecord::Base.connection)
        .to receive(:active?)
        .and_return(true)
    end

    it { is_expected.to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Database check',
        ok: true
      )
    end
  end

  context 'with an inactive database' do
    before do
      allow(ActiveRecord::Base.connection)
        .to receive(:active?)
        .and_return(false)
    end

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Database check',
        ok: false
      )
    end
  end

  context 'with an unreachable database' do
    before do
      allow(ActiveRecord::Base.connection)
        .to receive(:active?)
        .and_raise(PG::ConnectionBad, 'bad connection')
    end

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Database check',
        ok: false,
        error: 'bad connection'
      )
    end
  end

  context 'with another database exception' do
    before do
      allow(ActiveRecord::Base.connection)
        .to receive(:active?)
        .and_raise(StandardError, 'some other exception')
    end

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Database check',
        ok: false,
        error: 'some other exception'
      )
    end
  end
end
