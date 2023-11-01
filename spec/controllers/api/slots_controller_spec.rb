require "rails_helper"

RSpec.describe Api::SlotsController do
  render_views

  let(:parsed_body) { JSON.parse(response.body) }
  let(:prisoner)    { create(:prisoner) }

  describe '#index' do
    let(:params) {
      {
        format: :json,
        prison_id: prison.id,
        prisoner_number: prisoner.number,
        prisoner_dob: prisoner.date_of_birth,
        start_date: '2016-02-09',
        end_date: '2016-04-15'
      }
    }

    let(:slots) {
      {
        '2016-02-15T13:30/14:30' => [],
        '2016-03-02T13:30/14:30' => ['prisoner_unavailable'],
        '2016-03-03T13:30/14:30' => ['prisoner_unavailable']
      }
    }
    let(:offender_id) { 1_502_035 }

    before do
      stub_auth_token
    end

    context 'with auto slots enabled' do
      let(:prison) {
        create(:prison,
               booking_window: 28,
               lead_days: 3,
               nomis_concrete_slots: [
                       build(:nomis_concrete_slot, date: Date.new(2016, 2, 15), start_hour: 13, start_minute: 30, end_hour: 14, end_minute: 30),
                       build(:nomis_concrete_slot, date: Date.new(2016, 3, 2), start_hour: 13, start_minute: 30, end_hour: 14, end_minute: 30),
                       build(:nomis_concrete_slot, date: Date.new(2016, 3, 3), start_hour: 13, start_minute: 30, end_hour: 14, end_minute: 30)
                     ]).tap { |prison|
          switch_feature_flag_with(:public_prisons_with_slot_availability, [prison.name])
        }
      }

      before do
        stub_request(:get, "#{AuthHelper::API_PREFIX}/lookup/active_offender?date_of_birth=#{prisoner.date_of_birth}&noms_id=#{prisoner.number}")
          .to_return(body: { found: true, offender: { id: offender_id } }.to_json)

        stub_request(:get, "#{AuthHelper::API_PREFIX}/offenders/#{offender_id}/visits/available_dates?end_date=2016-03-08&start_date=2016-02-13")
          .to_return(body: { dates: ['2016-02-15'] }.to_json)

        stub_request(:get, "#{AuthHelper::API_PREFIX}/prison/#{prison.nomis_id}/slots?end_date=2016-03-12&start_date=2016-02-13")
            .to_return(body: { slots: [
                { time: "2016-02-15T13:30/14:30" },
                { time: "2016-03-02T13:30/14:30" },
                { time: "2016-03-03T13:30/14:30" },
            ] }.to_json)

        switch_feature_flag_with(:public_prisons_with_slot_availability, [prison.name])
      end

      it 'returns the list of slots with their availabilities' do
        get :index, params: params
        expect(parsed_body).to eq('slots' => slots)
      end
    end

    context 'with auto slots disabled' do
      let(:prison)      { create(:prison) }

      before do
        stub_request(:get, "#{AuthHelper::API_PREFIX}/offenders/#{offender_id}/visits/available_dates?end_date=2016-03-08&start_date=2016-02-09")
            .to_return(body: { dates: ['2016-02-15'] }.to_json)

        stub_request(:get, "#{AuthHelper::API_PREFIX}/lookup/active_offender?date_of_birth=#{prisoner.date_of_birth}&noms_id=#{prisoner.number}")
            .to_return(body: { found: true, offender: { id: offender_id } }.to_json)

        switch_feature_flag_with(:public_prisons_with_slot_availability, [])
      end

      it 'returns the list of slots with their availabilities' do
        get :index, params: params
        expect(parsed_body).to eq('slots' => { "2016-02-15T14:00/16:10" => [],
                                               "2016-02-16T09:00/10:00" => ["prisoner_unavailable"],
                                               "2016-02-16T14:00/16:10" => ["prisoner_unavailable"],
                                               "2016-02-22T14:00/16:10" => ["prisoner_unavailable"],
                                               "2016-02-23T09:00/10:00" => ["prisoner_unavailable"],
                                               "2016-02-23T14:00/16:10" => ["prisoner_unavailable"],
                                               "2016-02-29T14:00/16:10" => ["prisoner_unavailable"],
                                               "2016-03-01T09:00/10:00" => ["prisoner_unavailable"],
                                               "2016-03-01T14:00/16:10" => ["prisoner_unavailable"],
                                               "2016-03-07T14:00/16:10" => ["prisoner_unavailable"],
                                               "2016-03-08T09:00/10:00" => ["prisoner_unavailable"],
                                               "2016-03-08T14:00/16:10" => ["prisoner_unavailable"]
        })
      end
    end
  end
end
