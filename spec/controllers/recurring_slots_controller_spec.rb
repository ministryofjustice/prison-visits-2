require 'rails_helper'

RSpec.describe RecurringSlotsController, type: :controller do
  let!(:prison) { create(:prison_with_slots) }

  it 'should bounce when updating' do
    put :update, params: {prison_id: prison.id, locale: :en, day: :mon, slot_day: {end_date_dd: 27}}

    expect(assigns(:slot_day).errors).not_to be_empty
  end

  context 'with creation errors' do
    it 'should bounce when creating' do
      expect {
        post :create, params: {prison_id: prison.id, locale: :en, slot_day: {end_date_dd: 27}}
        expect(assigns(:slot_day)).not_to be_persisted
      }.not_to change(SlotDay, :count)
    end

    context 'when checking templates' do
      subject {
        post :create, params: {prison_id: prison.id, locale: :en, slot_day: {end_date_dd: 27}}
      }

      it 'should render new' do
        expect(subject).to render_template(:new)
      end
    end
  end
end
