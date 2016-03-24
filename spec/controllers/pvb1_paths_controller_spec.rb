require 'rails_helper'

RSpec.describe Pvb1PathsController, type: :controller do
  describe "#status" do
    subject { get :status, id: 'old-id' }

    it { is_expected.to be_not_found }
  end
end
