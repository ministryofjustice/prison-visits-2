require 'rails_helper'

RSpec.describe Healthcheck::QueueCheck do
  subject { described_class.new('Foo queue', queue_name: 'foo') }

  let(:queue) { [] }

  before do
    allow(Sidekiq::Queue).to receive(:new).and_return queue
  end

  it 'connects to the specified queue' do
    expect(Sidekiq::Queue).to receive(:new).with('foo').and_return queue
    subject.report
  end

  context 'with an empty queue' do
    it { is_expected.to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Foo queue',
        ok: true,
        oldest: nil,
        count: 0
      )
    end
  end

  context 'with only fresh queue items' do
    let(:created_at) { 9.minutes.ago }
    let(:queue) { [double(Sidekiq::Job, created_at:)] }

    it { is_expected.to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Foo queue',
        ok: true,
        oldest: created_at,
        count: 1
      )
    end
  end

  context 'when the Sidekiq API raises an exception' do
    before do
      allow(Sidekiq::Queue).to receive(:new).and_raise('queue problem')
    end

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Foo queue',
        ok: false,
        error: 'queue problem'
      )
    end
  end

  context 'with stale queue items' do
    let(:created_at) { 11.minutes.ago }
    let(:queue) { [double(Sidekiq::Job, created_at:)] }

    it { is_expected.not_to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'Foo queue',
        ok: false,
        oldest: created_at,
        count: 1
      )
    end
  end
end
