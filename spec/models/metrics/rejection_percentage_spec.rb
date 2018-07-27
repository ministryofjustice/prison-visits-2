require "rails_helper"

RSpec.describe Metrics::RejectionPercentage do
  Rejection::REASONS.each do |reason|
    it "##{reason} defaults to 0" do
      expect(subject.public_send(reason)).to eq(0)
    end
  end

  describe '#attributes' do
    it 'numeric attributes are initialised to 0' do
      expect(subject.as_json).to eq(child_protection_issues:    0,
                                    no_adult:                   0,
                                    no_allowance:               0,
                                    prisoner_details_incorrect: 0,
                                    prisoner_moved:             0,
                                    prisoner_non_association:   0,
                                    prisoner_out_of_prison:     0,
                                    prisoner_released:          0,
                                    slot_unavailable:           0,
                                    visitor_banned:             0,
                                    visitor_not_on_list:        0,
                                    duplicate_visit_request:    0,
                                    other:                      0,
                                    visitor_other_reason:       0,
                                    date:                       nil
                                   )
    end
  end
end
