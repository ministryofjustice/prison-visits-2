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
        date_of_birth:   prisoner.date_of_birth,
        start_date:      '2016-02-15',
        end_date:        '2016-04-15',
      }
    }

    let(:slots) {
      [
        { '2016-02-15T13:30/14:30' => true},
        { '2016-03-22T13:30/14:30' => false },
        { '2016-04-29T13:30/14:30' => false }
      ]
    }

    let(:prisoner_slot_availability) {
      double(PrisonerSlotAvailability, slots: slots)
    }

    before do
      expect(PrisonerSlotAvailability).to receive(:new).and_return(prisoner_slot_availability)
    end

    it 'returns the list of slots with there availabilities' do
      get :index, params
      expect(parsed_body).to eq('slots' => slots)
    end

  end
end
