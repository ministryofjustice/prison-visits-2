require 'rails_helper'

RSpec.describe MojHelper do
  it 'returns the phase' do
    expect(config_item(:phase)).to eq('live')
  end

  it 'returns the product type' do
    expect(config_item(:product_type)).to eq('service')
  end

  it 'returns the proposition title' do
    expect(config_item(:proposition_title))
      .to eq('Online visit requests')
  end
end
