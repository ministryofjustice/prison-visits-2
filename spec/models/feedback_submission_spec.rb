require 'rails_helper'

RSpec.describe FeedbackSubmission do
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

  describe 'email_address' do
    it 'returns default when not set' do
      expect(subject.email_address).
        to eq('feedback@email.prisonvisits.service.gov.uk')
    end

    it 'returns default when blank' do
      subject.email_address = ''
      expect(subject.email_address).
        to eq('feedback@email.prisonvisits.service.gov.uk')
    end

    it 'returns explicitly assigned value' do
      subject.email_address = 'user@test.example.com'
      expect(subject.email_address).
        to eq('user@test.example.com')
    end
  end
end
