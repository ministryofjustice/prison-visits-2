RSpec.shared_examples 'disallows untrusted ips' do
  context 'an untrusted ip' do
    before do request.headers['REMOTE_ADDR'] = '192.168.1.0' end

    it 'raises a not found error' do
      expect { subject }.to raise_error(ActionController::RoutingError)
    end
  end
end
