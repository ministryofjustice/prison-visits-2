require 'spec_helper'

RSpec.describe LinkDirectory do
  subject {
    described_class.new(prison_finder: 'http://pf.example.com/find{/prison}')
  }

  describe 'prison_finder' do
    it 'returns the base URL without a prison' do
      expect(subject.prison_finder).
        to eq('http://pf.example.com/find')
    end

    it 'appends the prison finder slug to the base URL' do
      prison = instance_double('Prison', finder_slug: 'luna')
      expect(subject.prison_finder(prison)).
        to eq('http://pf.example.com/find/luna')
    end
  end
end
