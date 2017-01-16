# frozen_string_literal: true
require 'rails_helper'
require_relative 'shared_examples_for_metrics'

RSpec.describe Percentiles do
  context 'that are not organised by date' do
    include_examples 'create and process visits timed by seconds'

    describe Percentiles::Distribution do
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

    describe Percentiles::DistributionByPrison do
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
                                                      } }
      end
    end
  end

  context 'that are organized by date' do
    include_examples 'create and process visits with dates'

    describe Percentiles::DistributionByPrisonAndCalendarWeek do
      before do
        luna_visits_with_dates
      end

      it 'counts visits and groups by prison, year, calendar week and visit state' do
        expect(described_class.fetch_and_format).to be ==
                                                    { 'Lunar Penal Colony' =>
                                                      {
                                                        2016 =>
                                                        { 5 =>
                                                          {
                                                            95 => 777_600,
                                                            99 => 777_600,
                                                            90 => 777_600,
                                                            75 => 777_600,
                                                            50 => 432_000,
                                                            25 => 259_200
                                                          },
                                                          6 =>
                                                          {
                                                            99 => 777_600,
                                                            95 => 777_600,
                                                            90 => 777_600,
                                                            75 => 777_600,
                                                            50 => 432_000,
                                                            25 => 259_200
                                                          },
                                                          7 => {
                                                            99 => 777_600,
                                                            95 => 777_600,
                                                            90 => 777_600,
                                                            50 => 432_000,
                                                            75 => 777_600,
                                                            25 => 259_200
                                                          } }
                                                      } }
      end

      context 'and aggregated across all prisons' do
        before do
          mars_visits_with_dates
          luna_visits_with_dates
        end

        it 'counts visits and groups by year, calendar week and visit state' do
          expect(described_class.fetch_and_format(:concatenate)).to be ==
                                                                    { 'all' =>
                                                                      {
                                                                        2016 =>
                                                                        { 5 =>
                                                                          {
                                                                            99 => 777_600,
                                                                            95 => 777_600,
                                                                            90 => 777_600,
                                                                            75 => 777_600,
                                                                            50 => 432_000,
                                                                            25 => 259_200
                                                                          },
                                                                          6 =>
                                                                          {
                                                                            99 => 777_600,
                                                                            95 => 777_600,
                                                                            90 => 777_600,
                                                                            75 => 777_600,
                                                                            50 => 432_000,
                                                                            25 => 259_200
                                                                          },
                                                                          7 => {
                                                                            99 => 777_600,
                                                                            95 => 777_600,
                                                                            90 => 777_600,
                                                                            75 => 777_600,
                                                                            50 => 432_000,
                                                                            25 => 259_200
                                                                          } }
                                                                      } }
        end
      end

      describe Percentiles::DistributionByPrisonAndCalendarDate do
        before do
          luna_visits_with_dates
        end

        it 'calculates distribution and groups by prison, nested calendar date and visit state' do
          expect(described_class.fetch_and_format).to be ==
                                                      { 'Lunar Penal Colony' =>
                                                        {
                                                          2016 =>
                                                          { 2 =>
                                                            {
                                                              1 =>
                                                              {
                                                                99 => 777_600,
                                                                95 => 777_600,
                                                                90 => 777_600,
                                                                75 => 777_600,
                                                                50 => 432_000,
                                                                25 => 259_200
                                                              },
                                                              8 =>
                                                              {
                                                                99 => 777_600,
                                                                95 => 777_600,
                                                                90 => 777_600,
                                                                75 => 777_600,
                                                                50 => 432_000,
                                                                25 => 259_200
                                                              },
                                                              15 => {
                                                                99 => 777_600,
                                                                95 => 777_600,
                                                                90 => 777_600,
                                                                75 => 777_600,
                                                                50 => 432_000,
                                                                25 => 259_200
                                                              }
                                                            } }
                                                        } }
        end

        context 'and aggregated across all prisons' do
          before do
            mars_visits_with_dates
            luna_visits_with_dates
          end

          it 'counts visits and groups by year, calendar week and visit state' do
            expect(described_class.fetch_and_format(:concatenate)).to be ==
                                                                      { 'all' =>
                                                                        {
                                                                          2016 =>
                                                                          { 2 =>
                                                                            {
                                                                              1 =>
                                                                              {
                                                                                99 => 777_600,
                                                                                95 => 777_600,
                                                                                90 => 777_600,
                                                                                75 => 777_600,
                                                                                50 => 432_000,
                                                                                25 => 259_200
                                                                              },
                                                                              8 =>
                                                                              {
                                                                                99 => 777_600,
                                                                                95 => 777_600,
                                                                                90 => 777_600,
                                                                                75 => 777_600,
                                                                                50 => 432_000,
                                                                                25 => 259_200
                                                                              },
                                                                              15 => {
                                                                                99 => 777_600,
                                                                                95 => 777_600,
                                                                                90 => 777_600,
                                                                                75 => 777_600,
                                                                                50 => 432_000,
                                                                                25 => 259_200
                                                                              }
                                                                            } }
                                                                        } }
          end
        end
      end
    end
  end
end
