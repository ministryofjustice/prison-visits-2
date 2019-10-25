# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnbookableDate, type: :model do
  let(:prison) { create(:prison) }
  let(:unbookable) { create(:unbookable_date, prison: prison) }
  let(:prison2) { create(:prison) }

  context 'when in same prison' do
    let(:date) { build(:unbookable_date, prison: prison, date: unbookable.date) }

    it 'prevents dups' do
      expect(date).not_to be_valid
      expect(date.errors.full_messages_for(:date)).to eq(['Date may not be duplicated'])
    end
  end

  it 'allows dups in different prisons' do
    expect(build(:unbookable_date, prison: prison2, date: unbookable.date)).to be_valid
  end

  context 'when an unbookable day is invalid' do
    it 'is invalid' do
      expect(
        build(:unbookable_date, date_dd: '99', date_mm: '99', date_yyyy: '9999')
      ).not_to be_valid
    end
  end
end
