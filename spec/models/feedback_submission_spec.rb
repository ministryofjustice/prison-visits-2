require 'rails_helper'

RSpec.describe FeedbackSubmission do
  context 'when performing validations' do
    context 'with an email_address' do
      it 'strips whitespace' do
        subject.email_address = ' user@example.com '
        subject.valid?
        expect(subject.email_address).to eq('user@example.com')
      end
    end
  end

  context 'with validations' do
    context 'with an email_address' do
      it 'is valid when absent' do
        subject.email_address = ''
        subject.validate
        expect(subject.errors).not_to have_key(:email_address)
      end

      context 'when the email checker returns true' do
        before do
          allow_any_instance_of(EmailAddressValidation::Checker)
            .to receive(:valid?).and_return(true)
        end

        it 'is valid' do
          subject.email_address = 'user@test.example.com'
          subject.validate
          expect(subject.errors).not_to have_key(:email_address)
        end
      end

      context 'when the email checker returns false' do
        before do
          allow_any_instance_of(EmailAddressValidation::Checker)
            .to receive(:valid?).and_return(false)
        end

        it 'is invalid when not an email address' do
          subject.email_address = 'BOGUS !'
          subject.validate
          expect(subject.errors).to have_key(:email_address)
        end
      end
    end

    context 'with a prisoner_number' do
      context 'when it is absent' do
        it 'no error on field' do
          subject.valid?
          expect(subject.errors).not_to have_key(:prisoner_number)
        end
      end

      context 'when it is invalid' do
        it 'error on the field' do
          subject.prisoner_number = 'bobbins'
          subject.valid?
          expect(subject.errors.full_messages_for(:prisoner_number))
            .to eq(['Prisoner number has an invalid format'])
        end
      end

      context 'when it is valid' do
        it 'no error on field' do
          subject.prisoner_number = 'A1234BC'
          subject.valid?
          expect(subject.errors).not_to have_key(:prisoner_number)
        end
      end
    end

    context 'with a prisoner_date_of_birth' do
      context 'when it is absent' do
        it 'no error on field' do
          subject.valid?
          expect(subject.errors).not_to have_key(:prisoner_date_of_birth)
        end
      end

      context 'when it is invalid' do
        it 'error on the field' do
          subject.prisoner_date_of_birth = Date.new(1066, 1, 1)
          subject.valid?
          expect(subject.errors.full_messages_for(:prisoner_date_of_birth))
            .to eq(['Prisoner date of birth must be less than 120 years ago'])
        end
      end

      context 'when it is valid' do
        it 'no error on field' do
          subject.prisoner_date_of_birth = Time.zone.today - 30.years
          subject.valid?
          expect(subject.errors).not_to have_key(:prisoner_date_of_birth)
        end
      end
    end
  end
end
