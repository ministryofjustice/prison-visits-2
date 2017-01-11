# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DashboardHelper do
  describe '#timeline_event_html_class' do
    subject { helper.timeline_event_html_class(event) }

    context 'for an event that is not the last event' do
      let(:event) { double('event', last: false, state: 'requested') }

      it 'does not have the last html class' do
        expect(subject).to eq('timeline__entry timeline__entry--requested')
      end
    end

    context 'for an event that is the last event' do
      let(:event) { double('event', last: true, state: 'requested') }

      it 'has the last html class' do
        expect(subject).to eq(
          'timeline__entry timeline__entry--requested timeline__entry-last'
        )
      end
    end
  end
end
