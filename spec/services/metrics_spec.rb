require 'rails_helper'

RSpec.describe Metrics do
  let(:prison) { create(:prison) }
  subject { described_class.new(prison) }

  describe 'end to end processing time' do
    let(:visits) { create_list(:visit, 4, prison: prison, created_at: 1.week.ago) }
    before do
      # requested -> booked, total time
      # 7 days ago -> 1 day ago, 6 days
      # 7 days ago -> 2 days ago 5 days
      # 7 days ago -> 3 days ago 4 days
      # 7 days ago -> 4 days ago 3 days
      # Average: (6 + 5 + 4 + 3)/4 = 4.5 days
      visits.each_with_index do |visit, i|
        travel_to (i + 1).days.ago do
          visit.accept!
        end
      end
    end

    it 'reports the avereage number of days' do
      expect(subject.end_to_end_processing_time).to eq(4.5)
    end
  end

  describe 'processing time' do

  end

  describe 'unconfirmed visits by time from today' do

  end

  describe 'time since last unconfirmed visit' do

  end

  describe 'when are visits processed?' do

  end

  describe 'when are visits requested?' do

  end
end

