require "rails_helper"

RSpec.describe VisitOrderType do
  let(:attributes) do
    {
      'type' => { 'code' => 'some code', 'desc' => 'some description' },
      'number' => '1234567890'
    }
  end

  let(:visit_order) { subject.cast(attributes) }

  it { expect(visit_order).to be_instance_of(Nomis::VisitOrder).and be_frozen }
  it { expect(visit_order).to have_attributes(number: 1_234_567_890, code: 'some code', desc: 'some description') }
end
