require 'rails_helper'

RSpec.describe AdditionalVisitor do
  it { is_expected.to belong_to(:visit) }
  it { is_expected.to validate_presence_of(:visit_id) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:date_of_birth) }
end
