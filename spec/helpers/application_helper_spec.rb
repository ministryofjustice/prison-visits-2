require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe 'markdown' do
    it 'converts the provided markdown source to html' do
      expect(markdown('# hello')).to eql("<h1 id=\"hello\">hello</h1>\n")
    end
  end
end
