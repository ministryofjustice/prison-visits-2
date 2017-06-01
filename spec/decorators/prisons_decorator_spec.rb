require "rails_helper"

RSpec.describe PrisonsDecorator, type: :decorator do
  let!(:prisons) { create_list :prison, size }

  subject { described_class.decorate Prison.all }

  describe 'with less than 3 prisons' do
    let(:size) { 2 }

    it { expect(subject.slab_size).to eq(2) }
  end

  describe 'with more than 3 prisons' do
    let(:size) { 6 }

    it { expect(subject.slab_size).to eq(size / described_class::GRID_COLUMNS) }
  end
end
