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
        allow(helper)
          .to receive(:params)
          .and_return(controller: 'prison/dashboards',
                      action: 'inbox',
                      prisoner_number: 'A1234BC')
      end

      it 'adds an active class' do
        expect(subject).to match('class="active"')
      end
    end

    context 'when is not the current page' do
      before do
        allow(helper)
          .to receive(:params)
          .and_return(controller: 'prison/dashboards', action: 'processed')
      end

      it 'does not add an active class' do
        expect(subject).not_to match('class="active"')
      end
    end
  end

  describe 'javascript_i18n' do
    it 'includes the days of the week' do
      expect(javascript_i18n).to include(
        days: %w[ Sunday Monday Tuesday Wednesday Thursday Friday Saturday ]
      )
    end

    it 'includes the months of the year with January at index 0' do
      # JavaScript follows the libc convention of 0 = January etc.
      expect(javascript_i18n).to include(
        months: %w[
          January
          February
          March
          April
          May
          June
          July
          August
          September
          October
          November
          December
        ]
      )
    end

    it 'includes abbreviated months of the year with January at index 0' do
      # JavaScript follows the libc convention of 0 = January etc.
      expect(javascript_i18n).to include(
        abbrMonths: %w[ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ]
      )
    end

    it 'includes am/pm' do
      expect(javascript_i18n).to include(am: 'am', pm: 'pm')
    end

    it 'includes minutes and hours' do
      expect(javascript_i18n).to include(
        minute: {
          one: 'min',
          other: 'mins'
        },
        hour: {
          one: 'hr',
          other: 'hrs'
        }
      )
    end
  end
end
