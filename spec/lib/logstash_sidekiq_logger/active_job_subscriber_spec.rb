require 'rails_helper'
require 'logstash_sidekiq_logger'

RSpec.describe LogstashSidekiqLogger::ActiveJobSubscriber do
  let(:instance) { described_class.new }

  describe "#perform" do
    let(:job_payload) { double }

    let(:event) do
      ActiveSupport::Notifications::Event.new(
        'active_job.perform',
        Time.zone.now,
        Time.zone.now,
        2,
        payload: job_payload
      )
    end

    subject(:perform) { instance.perform(event) }

    it 'stores the job event' do
      perform
      expect(RequestStore.store[:performed_job]).to eq(event)
    end
  end
end
