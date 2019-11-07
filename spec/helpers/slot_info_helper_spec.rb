require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SlotInfoHelper. For example:
#
# describe SlotInfoHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SlotInfoHelper, type: :helper do
  let(:slot) { '1400-1610' }

  subject  {  helper.colon_formatted_slot(slot) }

  describe '#formatted' do
    it { expect(subject).to eq('14:00 - 16:10') }
  end
end
