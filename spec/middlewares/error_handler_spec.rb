require 'rails_helper'

RSpec.describe ErrorHandler do
  describe '.call' do
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
  end
end
