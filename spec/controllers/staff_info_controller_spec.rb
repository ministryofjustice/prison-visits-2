require 'rails_helper'
require_relative 'untrusted_examples'

RSpec.describe StaffInfoController, type: :controller do
  around do |ex|
    VCR.turned_off { ex.run }
  end

  before do
    allow(Rails.configuration).to receive(:staff_info_endpoint).
      and_return('http://example.com')
  end

  describe 'when endpoint is not set' do
    before do
      allow(Rails.configuration).to receive(:staff_info_endpoint).
        and_return(nil)
    end

    subject do
      get :index
    end

    it { is_expected.to render_template(:not_available) }
  end

  describe 'index' do
    before do
      stub_request(:get, "http://example.com/").
        to_return(status: 200)
    end

    subject do
      get :index
    end

    it { expect(response.status).to eq(200) }
    it { is_expected.to render_template(:index) }
    it_behaves_like 'disallows untrusted ips'
  end

  describe 'show' do
    let!(:stub_navbar) do
      stub_request(:get, "http://example.com/nav.md").to_return(status: 200)
    end

    context 'available page' do
      before do
        stub_request(:get, /changes\.md/).
          to_return(status: 200,
                    body: '# Markdown',
                    headers: { 'Content-Type' => 'text/markdown' })
      end

      subject do
        get :show, page: 'changes.md'
      end

      it { expect(response.status).to eq(200) }
      it { is_expected.to render_template(:show) }
      it_behaves_like 'disallows untrusted ips'
    end

    context 'pdf downloads' do
      before do
        stub_request(:get, /acrobat\.pdf/).
          to_return(status: 200,
                    body: 'pdf stuff',
                    headers: { 'Content-Type' => 'application/pdf' })
      end

      subject do
        get :show, page: 'acrobat.pdf'
      end

      it { is_expected.to have_http_status(200) }
      it_behaves_like 'disallows untrusted ips'
    end

    context 'errors' do
      subject do
        get :show, page: :wildweasel
      end

      context 'missing page' do
        before do
          stub_request(:get, /wildweasel/).to_return(status: 404)
        end

        it {
          expect { subject }.
            to raise_error(ActionController::RoutingError, 'Not Found')
        }
        it_behaves_like 'disallows untrusted ips'
      end

      context 'service unavailable' do
        before do
          stub_request(:get, /wildweasel/).to_return(status: 503)
        end

        it { is_expected.to render_template(:not_available) }
        it_behaves_like 'disallows untrusted ips'
      end

      context 'service unavailable' do
        before do
          stub_request(:get, /wildweasel/).to_return(status: 500)
        end

        it { is_expected.to render_template(:not_available) }
        it_behaves_like 'disallows untrusted ips'
      end

      context 'timeout' do
        before do
          stub_request(:get, /wildweasel/).to_return(status: 408)
        end

        it { is_expected.to render_template(:not_available) }
      end
    end

    describe '.markdown' do
      context 'valid encoding' do
        let(:markdown) { '#Markdown' }

        it 'renders markdown' do
          expect(controller.send(:markdown, markdown)).
            to eq("<h1>Markdown</h1>\n")
        end
      end

      context 'bad encoding' do
        let(:markdown) { "#Markdown \xE2".force_encoding('ASCII-8BIT') }

        it 'renders markdown with unknown character' do
          expect(controller.send(:markdown, markdown)).
            to eq("<h1>Markdown �</h1>\n")
        end
      end
    end
  end
end
