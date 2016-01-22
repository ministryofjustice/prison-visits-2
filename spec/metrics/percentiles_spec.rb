require 'rails_helper'

RSpec.describe Percentiles do
  let(:luna) { create(:prison, name: 'Lunar Penal Colony') }
  let(:mars) { create(:prison, name: 'Martian Penal Colony') }

  before do
    [luna, mars].each do |prison|
      travel_to Time.zone.local(2016, 3, 1, 13, 0, 0) do
        @visits = create_list(:visit, 10, prison: prison)
      end

      @visits.each_with_index do |visit, i|
        seconds = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55].fetch(i)
        travel_to Time.zone.local(2016, 3, 1, 13, 0, seconds) do
          visit.accept!
        end
      end
    end
  end

  describe Percentiles::CalculateDistributions do
    it 'returns the 99% 95% 90% 75% 50% 25% times' do
      expect(described_class.fetch_and_format).to be ==
        {
        99 => 55,
        95 => 55,
        90 => 34,
        75 => 21,
        50 => 5,
        25 => 2
      }
    end
  end

  describe Percentiles::CalculateDistributionsForPrisons do
    it 'returns the 99% 95% 90% 75% 50% 25% times' do
      expect(described_class.fetch_and_format).to be ==
        { 'Lunar Penal Colony' =>
          {
            99 => 55,
            95 => 55,
            90 => 34,
            75 => 21,
            50 => 5,
            25 => 2
          },
          'Martian Penal Colony' =>
          {
            99 => 55,
            95 => 55,
            90 => 34,
            75 => 21,
            50 => 5,
            25 => 2
          }
        }
    end
  end
end
