require 'rails_helper'

RSpec.feature 'PVB1 old links', js: true do
  it 'renders an appropiate message' do
    visit(pvb1_status_path(id: 'old-id'))

    expect(page).to have_text('Visit expired')
  end
end
