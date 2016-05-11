require 'rails_helper'

RSpec.describe ErrorHandler do
  describe '.call' do
    let(:query_string) { 'anything' }
    let(:env) do
      {
        'QUERY_STRING' => query_string,
        'PATH_INFO' => '/500'
      }
    end

    subject { described_class.call(env) }

    let(:show_action) { double('Show action', call: true) }

    before do
      expect(ErrorsController).
        to receive(:action).with(:show).and_return(show_action)
    end

    context 'with a valid query string' do
      let!(:query_string) { 'a=b' }

      it 'calls the error controller with the original query string' do
        expect(show_action).to receive(:call).with(env)
        subject
      end
    end

    context 'with an invalid query string' do
      let!(:query_string) { 'b=1&b[a]=2' }

      it 'calls the error controller with a blank query string' do
        new_env = env.dup
        new_env['QUERY_STRING'] = ''

        expect(show_action).to receive(:call).with(new_env)
        subject
      end
    end

    context 'error handling' do
      let(:error) { StandardError.new }

      before do
        expect(show_action).to receive(:call).with(env).and_raise(error)
      end

      it 'reports the error to sentry and reraises' do
        expect(Raven).to receive(:capture_exception).with(error)
        expect { subject }.to raise_error(error)
      end
    end
  end
end
