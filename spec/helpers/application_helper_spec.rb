require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe 'markdown' do
    it 'converts the provided markdown source to html' do
      expect(markdown('# hello')).to eql("<h1 id=\"hello\">hello</h1>\n")
    end
  end

  describe 'alternative_locales' do
    it 'lists all available locales except the current one' do
      I18n.locale = :cy
      expect(alternative_locales).to eq(%i[ en ])
    end
  end

  describe 'nav_link' do
    let(:link_text) { 'link_text' }
    let(:link_path) { 'prison/inbox' }

    subject { helper.nav_link(link_text, link_path) }

    context 'when is the current page' do
      before do
        allow(helper).
          to receive(:params).
          and_return(controller: 'prison/dashboards',
                     action: 'inbox',
                     prisoner_number: 'A1234BC')
      end

      it 'adds an active class' do
        is_expected.to match('class="active"')
      end
    end

    context 'when is not the current page' do
      before do
        allow(helper).
          to receive(:params).
          and_return(controller: 'prison/dashboards', action: 'processed')
      end

      it 'does not add an active class' do
        is_expected.not_to match('class="active"')
      end
    end
  end
end
