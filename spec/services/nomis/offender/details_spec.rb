require "rails_helper"

RSpec.describe Nomis::Offender::Details do
  it { is_expected.to respond_to :given_name }
  it { is_expected.to respond_to :surname }
  it { is_expected.to respond_to :middle_names }
  it { is_expected.to respond_to :date_of_birth }
  it { is_expected.to respond_to :aliases }
  it { is_expected.to respond_to :gender }
  it { is_expected.to respond_to :convicted }
  it { is_expected.to respond_to :imprisonment_status }
  it { is_expected.to respond_to :iep_level }
end
