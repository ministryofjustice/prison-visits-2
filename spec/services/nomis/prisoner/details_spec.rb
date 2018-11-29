require "rails_helper"

RSpec.describe Nomis::Prisoner::Details do
  it { is_expected.to respond_to :aliases }
  it { is_expected.to respond_to :api_call_successful }
  it { is_expected.to respond_to :convicted }
  it { is_expected.to respond_to :cro_number }
  it { is_expected.to respond_to :csra }
  it { is_expected.to respond_to :date_of_birth }
  it { is_expected.to respond_to :diet }
  it { is_expected.to respond_to :ethnicity }
  it { is_expected.to respond_to :gender }
  it { is_expected.to respond_to :given_name }
  it { is_expected.to respond_to :iep_level }
  it { is_expected.to respond_to :imprisonment_status }
  it { is_expected.to respond_to :language }
  it { is_expected.to respond_to :middle_names }
  it { is_expected.to respond_to :nationalities }
  it { is_expected.to respond_to :pnc_number }
  it { is_expected.to respond_to :religion }
  it { is_expected.to respond_to :surname }
  it { is_expected.to respond_to :title }
end
