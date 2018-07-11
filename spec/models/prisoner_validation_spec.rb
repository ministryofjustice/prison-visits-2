require 'rails_helper'

RSpec.describe PrisonerValidation, type: :model do
  let(:prisoner) do
    Nomis::Prisoner.new(id: 'someid', noms_id: 'a1234bc')
  end

  subject do
    described_class.new(prisoner)
  end

  context 'when the API finds a match' do
    context 'with a prisoner number, dob' do
      it { is_expected.to be_valid }
    end
  end

  context 'when the API does not find a match' do
    let(:prisoner) { Nomis::NullPrisoner.new(api_call_successful: success) }

    describe 'with a successful API call' do
      let(:success) { true }

      it { is_expected.not_to be_valid }
    end

    context 'with an unsuccessful API call' do
      let(:success) { false }

      it { is_expected.to be_invalid }
    end
  end
end
