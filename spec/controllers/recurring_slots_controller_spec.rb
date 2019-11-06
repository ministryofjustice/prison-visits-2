require 'rails_helper'

RSpec.describe RecurringSlotsController, type: :controller do
  let(:prison) { create(:prison_with_slots) }

  it 'should bounce when updating' do
    put :update, params: {prison_id: prison.id, locale: :en, day: :mon, slot_day: {end_date_dd: 27}}

    expect(assigns(:slot_day).errors).not_to be_empty
  end
end
