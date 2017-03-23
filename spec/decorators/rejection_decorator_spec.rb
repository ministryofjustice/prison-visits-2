require "rails_helper"

RSpec.describe RejectionDecorator do
  let(:allowance_renews_on) { 2.days.from_now.to_date }
  let!(:visit) { create(:rejected_visit) }
  let!(:unlisted_visitor) do
    create(:visitor, visit: visit, not_on_list: true)
  end
  let!(:banned_visitor) do
    create(:visitor, visit: rejection.visit, banned: true)
  end
  let(:rejection) { visit.rejection }

  before do
    visit.reload
  end

  subject { described_class.decorate(rejection) }

  describe '#formatted_reasons' do
    before do
      rejection.reasons = reasons
    end

    context 'containing slot_unavailable' do
      let(:reasons) { [Rejection::SLOT_UNAVAILABLE] }

      it 'has the correct explanation' do
        expect(
          subject.formatted_reasons.map(&:explanation)
        ).to eq([
          "the dates and times you chose aren't available - choose new dates on <a href=\"www.gov.uk/prison-visits\">www.gov.uk/prison-visits</a>"
        ])
      end

      context 'containing no_allowance' do
        let(:reasons) { [Rejection::NO_ALLOWANCE] }

        context 'with a date set' do
          before do
            rejection.assign_attributes(
              allowance_renews_on: allowance_renews_on
            )
          end

          it 'has the correct explanation' do
            expect(
              subject.formatted_reasons.map(&:explanation)
            ).to eq([
              "the prisoner has used their allowance of visits for this month - you can only book a visit from #{I18n.l(rejection.allowance_renews_on, format: :date_without_year)} onwards"
            ])
          end
        end

        context 'without a date' do
          it 'has the correct explanation' do
            expect(
              subject.formatted_reasons.map(&:explanation)
            ).to eq([
              "the prisoner has used their allowance of visits for this month"
            ])
          end
        end
      end

      context 'containing not_on_list' do
        let(:reasons) { [Rejection::NOT_ON_THE_LIST] }

        it 'has the correct explanation' do
          expect(
            subject.formatted_reasons.map(&:explanation)
          ).to eq([
            "details for #{unlisted_visitor.anonymized_name} don't match our records or  aren't on the prisoner's contact list - ask the prisoner to update their contact list with correct details, making sure that names appear exactly the same as on ID documents; if this is the prisoner's first visit (reception visit), then you need to contact the prison directly to book"
          ])
        end
      end

      context 'containing banned' do
        let(:reasons) { [Rejection::BANNED] }

        it 'has the correct explanation' do
          expect(
            subject.formatted_reasons.map(&:explanation)
          ).to eq([
            "#{banned_visitor.anonymized_name} is banned from visiting the prison at the moment and should have received a letter from the prison."
          ])
        end
      end

      context 'containing both child protection issues and no association' do
        let(:reasons) do
          [
            Rejection::CHILD_PROTECTION_ISSUES,
            Rejection::PRISONER_NON_ASSOCIATION
          ]
        end

        it 'only as the explanation once' do
          expect(
            subject.formatted_reasons.map(&:explanation)
          ).to eq(['the prisoner has a restriction'])
        end
      end

      context 'containing both a no association and another non-restriction reason' do
        let(:reasons) do
          [
            Rejection::PRISONER_NON_ASSOCIATION,
            'prisoner_released'
          ]
        end

        it 'has a restricted and non restricted reasons' do
          expect(subject.formatted_reasons.map(&:explanation)).
            to contain_exactly('the prisoner has a restriction',
              'the prisoner has been released - hopefully they will contact you soon')
        end
      end
    end
  end

  describe '#allowance_renews_on' do
    context 'with a date' do
      before do
        rejection.assign_attributes(
          allowance_renews_on: allowance_renews_on
        )
      end

      it 'returns an accessible date' do
        expect(subject.allowance_renews_on).to be_instance_of(AccessibleDate)
      end

      it 'has the correct date' do
        expect(subject.allowance_renews_on.to_date).to eq(allowance_renews_on)
      end
    end

    context 'with no date' do
      let(:allowance_renews_on) { nil }

      it 'returns an accessible date' do
        expect(subject.allowance_renews_on).to be_instance_of(AccessibleDate)
      end

      it 'is nil' do
        expect(subject.allowance_renews_on.to_date).to eq(nil)
      end
    end
  end

  describe 'prisoner unvisitable checkboxes' do
    let(:visit_decorator) do
      double('VisitDecorator', prisoner_details_incorrect?: details_incorrect)
    end

    let(:nomis_checker) do
      double('StaffNomisChecker')
    end

    before do
      allow(nomis_checker).to receive(:error_in_any_slot?).and_return(false)
      allow(nomis_checker).to receive(:error_in_any_slot?).with(nomis_reason).
        and_return(true)

      subject.apply_nomis_reasons(visit_decorator, nomis_checker)
    end

    shared_examples_for :unchecked do |checkbox_name|
      let(:checkbox) do
        subject.checkbox_for(checkbox_name)
      end

      it "#{checkbox_name} is not checked" do
        expect(/checked="checked"/ =~ checkbox).to eq(nil)
      end
    end

    shared_examples_for :checked do |checkbox_name|
      let(:checkbox) do
        subject.checkbox_for(checkbox_name)
      end

      it "#{checkbox_name} is checked" do
        expect(/checked="checked"/ =~ checkbox).not_to eq(nil)
      end
    end

    context 'no unvisitable reasons' do
      let(:details_incorrect) { false }
      let(:nomis_reason) { nil }

      it_behaves_like :unchecked, :prisoner_details_incorrect
      it_behaves_like :unchecked, :no_allowance
      it_behaves_like :unchecked, :prisoner_banned
      it_behaves_like :unchecked, :prisoner_out_of_prison
    end

    context 'prisoner details incorrect' do
      let(:details_incorrect) { true }
      let(:nomis_reason) { nil }

      it_behaves_like :checked, :prisoner_details_incorrect
      it_behaves_like :unchecked, :no_allowance
      it_behaves_like :unchecked, :prisoner_banned
      it_behaves_like :unchecked, :prisoner_out_of_prison
    end

    context 'no allowance' do
      let(:details_incorrect) { false }
      let(:nomis_reason) { Nomis::PrisonerDateAvailability::OUT_OF_VO }

      it_behaves_like :unchecked, :prisoner_details_incorrect
      it_behaves_like :checked, :no_allowance
      it_behaves_like :unchecked, :prisoner_banned
      it_behaves_like :unchecked, :prisoner_out_of_prison
    end

    context 'prisoner banned' do
      let(:details_incorrect) { false }
      let(:nomis_reason) { Nomis::PrisonerDateAvailability::BANNED }

      it_behaves_like :unchecked, :prisoner_details_incorrect
      it_behaves_like :unchecked, :no_allowance
      it_behaves_like :checked, :prisoner_banned
      it_behaves_like :unchecked, :prisoner_out_of_prison
    end

    context 'prisoner out of prison' do
      let(:details_incorrect) { false }
      let(:nomis_reason) { Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT }

      it_behaves_like :unchecked, :prisoner_details_incorrect
      it_behaves_like :unchecked, :no_allowance
      it_behaves_like :unchecked, :prisoner_banned
      it_behaves_like :checked, :prisoner_out_of_prison
    end
  end
end
