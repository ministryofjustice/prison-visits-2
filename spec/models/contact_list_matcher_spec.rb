require "rails_helper"

RSpec.shared_examples 'no exact match nor near match' do
  it 'has no exact matched contact' do
    expect(exact_matches.contacts).to be_empty
  end

  it 'has no partially matched contacts' do
    expect(nearest_matches.contacts).to be_empty
  end

  it 'has unmatched contacts' do
    expect(others.contacts.map(&:id).sort).to eq(contact_list.map(&:id).sort)
  end
end

RSpec.describe ContactListMatcher do
  let(:fourties)     { build(:contact, date_of_birth: 43.years.ago)  }
  let(:thirties)     { build(:contact, date_of_birth: 34.years.ago)  }
  let(:twenties)     { build(:contact, date_of_birth: 29.years.ago)  }
  let(:contact_list) { [twenties, thirties, fourties] }
  let(:visitor)      { create(:visitor, date_of_birth: 19.years.ago) }

  let(:exact_matches) do
    matches.detect { |m| m.is_a?(ContactListMatcher::ExactMatches) }
  end

  let(:nearest_matches) do
    matches.detect { |m| m.is_a?(ContactListMatcher::NearestMatches) }
  end

  let(:others) do
    matches.detect { |m| m.is_a?(ContactListMatcher::Others) }
  end

  let(:matches)    { subject.matches }

  subject { described_class.new(contact_list, visitor) }

  describe '#empty?' do
    context 'whithout any contact' do
      let(:contact_list) { [] }

      it { is_expected.to be_empty }
    end

    context 'with contacts' do
      it { is_expected.not_to be_empty }
    end
  end

  describe '#matches' do
    context 'with a matching date of birth' do
      before do
        visitor.date_of_birth = contact_list.first.date_of_birth
      end

      context 'and the name does not match' do
        it_behaves_like 'no exact match nor near match'
      end

      context 'and the name matches exactly' do
        before do
          visitor.first_name = contact_list.first.given_name
          visitor.last_name = contact_list.first.surname
        end

        it 'is has an exact match' do
          expect(exact_matches.contacts.first).to eq(contact_list.first)
        end

        context 'when a name is partially matched, about 2 typos' do
          before do
            visitor.first_name[-1] = visitor.first_name[-1].next
          end

          it 'has a partially match' do
            expect(nearest_matches.contacts.map(&:id).sort).to eq([contact_list.first.id])
          end

          context 'with 3 typos' do
            before do
              visitor.first_name[-1] = visitor.first_name[-1].next
              visitor.first_name[1]  = visitor.first_name[1].next
              visitor.first_name     = "#{visitor.first_name}#{visitor.first_name[-1]}"
            end

            it 'has a partially match' do
              expect(nearest_matches.contacts).to be_empty
            end
          end
        end
      end
    end

    context 'with a non matching date of birth' do
      it_behaves_like 'no exact match nor near match'
    end
  end
end
