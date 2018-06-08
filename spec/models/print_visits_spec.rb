require 'rails_helper'

RSpec.describe PrintVisits, type: :model do
  let(:error_message) { "Please choose a date within the last six months, or <a href='%<url>s'>contact us</a> if you would like to see older visits." }

  context 'with validations' do
    context 'when the date is out of the the given range' do
      it 'has an error on the field' do
        subject.visit_date = '2017-01-01'
        subject.validate
        expect(subject.errors.messages[:base]).to include(error_message)
      end
    end

    context 'when the date is within the the given range' do
      it 'has no error on the field' do
        subject.visit_date = 3.months.ago.strftime("%F")
        subject.validate
        expect(subject.errors.messages[:base]).not_to include(error_message)
      end
    end
  end
end
