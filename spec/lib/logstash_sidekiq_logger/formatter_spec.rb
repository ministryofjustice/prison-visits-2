require 'rails_helper'
require 'logstash_sidekiq_logger/formatter'

RSpec.describe LogstashSidekiqLogger::Formatter do
  let(:visit) { FactoryBot.create(:visit) }
  let(:formatter) { described_class.new }
  let(:done_message) { 'done: 2.944 sec' }
  let(:fail_message) { 'fail: 2.945 sec' }
  let(:fail_hash_message) do
    {
      "class" => "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper",
      "wrapped" => "ActionMailer::DeliveryJob",
      "queue" => "mailers",
      "args" => job_args,
      "locale" => "en",
      "retry" => can_retry_job,
      "jid" => "12db1b5e9b9ce2f1d69a06f8",
      "created_at" => 1_466_168_392.384784,
      "enqueued_at" => 1_466_168_392.384825,
      "error_message" => "",
      "error_class" => "RuntimeError",
      "failed_at" => 1_466_168_392.5716329,
      "retry_count" => 0
    }
  end
  let(:job_args) do
    [{
      "job_class" => "ActionMailer::DeliveryJob",
      "job_id" => "5962f204-9f90-4196-95bd-c7db08a9c8dd",
      "queue_name" => "mailers",
      "arguments" => ["VisitorMailer",
                      "booked",
                      "deliver_now!",
                      { "_aj_globalid" => visit.to_global_id }]
    }]
  end

  after do
    RequestStore.clear!
  end

  describe '#call' do
    subject(:call) { formatter.call(anything, anything, anything, message) }

    let(:logged_message) do
      raw_message = call
      raw_message ? JSON.parse(raw_message.chomp) : nil
    end

    describe 'without a stored active job event' do
      before do
        RequestStore.store[:performed_job] = nil
      end

      let(:message) { done_message }

      it 'does not log a message' do
        expect(logged_message).to be_nil
      end
    end

    describe 'with a stored active job event' do
      let(:job_event) do
        double(
          'ActiveSupportNotification',
          duration: 1234,
          payload: {
            job: double(arguments: ['VisitorMailer', 'cancelled', visit, 'foo'],
                        queue_name: 'mailers')
          })
      end

      before do
        RequestStore.store[:performed_job] = job_event
      end

      describe 'a random sidekiq message' do
        let(:message) { 'rand: 2.944 sec' }

        it 'does not output a message' do
          expect(logged_message).to be_nil
        end

        it 'does not clear the request store' do
          call
          expect(RequestStore.store[:performed_job]).to eq(job_event)
        end
      end

      describe 'with a successful job' do
        let(:message) { done_message }

        it 'outputs a message' do
          expect(logged_message)
            .to include(
              'job_name' => 'visitor_mailer_cancelled',
              'arguments' => [visit.to_global_id.to_s, 'foo'],
              'queue_name' => 'mailers',
              'job_status' => 'completed',
              'active_job_duration' => 1234,
              'total_duration' => 2944)
          expect(logged_message['message'])
            .to match(Regexp.quote('[completed] (2944.0 ms)'))
        end

        it 'clears the request store' do
          call
          expect(RequestStore.store[:performed_job]).to be_nil
        end
      end

      describe 'with the first failure message' do
        let(:message) { fail_message }

        it 'does not output a message' do
          expect(logged_message).to be_nil
        end

        it 'does not clear the request store' do
          call
          expect(RequestStore.store[:performed_job]).to eq(job_event)
        end
      end

      describe 'with the retriable failure message' do
        before do
          formatter.call(anything, anything, anything, fail_message)
        end

        let(:message) { fail_hash_message }
        let(:can_retry_job) { true }

        it 'outputs a message' do
          expect(logged_message)
            .to include(
              'job_name' => 'visitor_mailer_cancelled',
              'arguments' => [visit.to_global_id.to_s, 'foo'],
              'queue_name' => 'mailers',
              'job_status' => 'to_be_retried',
              'active_job_duration' => 1234,
              'total_duration' => 2945,
              "retry_count" => 0)
          expect(logged_message['message'])
            .to match(Regexp.quote('[to_be_retried] (2945.0 ms)'))
        end

        it 'clears the request store' do
          call
          expect(RequestStore.store[:performed_job]).to be_nil
        end
      end

      describe 'with the a non-retriable failure message' do
        before do
          formatter.call(anything, anything, anything, fail_message)
        end

        let(:can_retry_job) { false }
        let(:message) { fail_hash_message }

        it 'outputs a message' do
          expect(logged_message)
            .to include(
              'job_name' => 'visitor_mailer_cancelled',
              'arguments' => [visit.to_global_id.to_s, 'foo'],
              'queue_name' => 'mailers',
              'job_status' => 'failed',
              'active_job_duration' => 1234,
              'total_duration' => 2945,
              "retry_count" => 0)
          expect(logged_message['message'])
            .to match(Regexp.quote('[failed] (2945.0 ms)'))
        end

        it 'clears the request store' do
          call
          expect(RequestStore.store[:performed_job]).to be_nil
        end
      end
    end
  end
end
