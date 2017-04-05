require "rails_helper"

RSpec.describe Api::SlotsController do
  render_views

  let(:parsed_body) { JSON.parse(response.body) }
  let(:prisoner)    { create(:prisoner) }
  let(:prison)      { create(:prison) }

  describe '#index' do
    let(:params) {
      {
        format: :json,
        prison_id:       prison.id,
        prisoner_number: prisoner.number,
        prisoner_dob:    prisoner.date_of_birth,
        start_date:      '2016-02-15',
        end_date:        '2016-04-15'
      }
    }

    let(:slots) {
      [
        { '2016-02-15T13:30/14:30' => [] },
        { '2016-03-22T13:30/14:30' => ['prisoner_unavailable'] },
        { '2016-04-29T13:30/14:30' => ['prisoner_unavailable'] }
      ]
    }

    let(:all_slots) {
      [
        { '2016-02-15T13:30/14:30' => [] },
        { '2016-03-22T13:30/14:30' => [] },
        { '2016-04-29T13:30/14:30' => [] }
      ]
    }

    let(:prisoner_slot_availability) {
      double(SlotAvailability, slots: slots, all_slots: all_slots)
    }

    before do
      expect(SlotAvailability).to receive(:new).
        and_return(prisoner_slot_availability)
    end

    context 'response within permitted time limit' do
      it 'returns the list of slots with their availabilities' do
        get :index, params
        expect(parsed_body).to eq('slots' => slots)
      end
    end

    context 'response outside permitted time limit' do
      before do
        allow_any_instance_of(Timebox).to receive(:seconds_expired?).
          and_return(true)
      end

      it 'returns the list of slots without their availabilities' do
        get :index, params
        expect(parsed_body).to eq('slots' => all_slots)
      end
    end
  end
end
