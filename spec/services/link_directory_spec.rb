require 'rails_helper'

RSpec.describe LinkDirectory do
  subject {
    described_class.new(
      prison_finder: 'http://pf.example.com/find{/prison}',
      public_service: 'http://localhost:4000'
    )
  }

  describe 'prison_finder' do
    it 'returns the base URL without a prison' do
      expect(subject.prison_finder)
        .to eq('http://pf.example.com/find')
    end

    it 'appends the prison finder slug to the base URL' do
      prison = instance_double('Prison', finder_slug: 'luna')
      expect(subject.prison_finder(prison))
        .to eq('http://pf.example.com/find/luna')
    end
  end

  describe '#visit_status' do
    it 'generates a visit status link' do
      visit = build_stubbed(:visit, human_id: 'FOOBAR')
      expect(subject.visit_status(visit))
        .to eq('http://localhost:4000/en/visits/FOOBAR')
    end
  end

  it 'generates feedback links' do
    expect(subject.feedback_submission)
      .to eq('http://localhost:4000/en/feedback/new')
  end
end
