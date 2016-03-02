require 'rails_helper'

RSpec.describe FeedbackSubmission do
  context 'before validations' do
    context 'email_address' do
      it 'strips whitespace' do
        subject.email_address = ' user@example.com '
        subject.valid?
        expect(subject.email_address).to eq('user@example.com')
      end
    end
  end

  context 'validations' do
    context 'email_address' do
      it 'is valid when absent' do
        subject.email_address = ''
        subject.validate
        expect(subject.errors).not_to have_key(:email_address)
      end

      it 'is valid when reasonable' do
        subject.email_address = 'user@test.example.com'
        subject.validate
        expect(subject.errors).not_to have_key(:email_address)
      end

      it 'is invalid when not an email address' do
        subject.email_address = 'BOGUS!'
        subject.validate
        expect(subject.errors).to have_key(:email_address)
      end
    end
  end
end
