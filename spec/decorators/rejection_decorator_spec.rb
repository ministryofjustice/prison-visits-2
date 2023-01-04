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

  describe '#email_formatted_reasons' do
    before do
      rejection.reasons = reasons
    end

    context 'when containing slot_unavailable' do
      let(:reasons) { [Rejection::SLOT_UNAVAILABLE] }

      it 'has the correct explanation' do
        expect(
          subject.email_formatted_reasons.map(&:explanation)
        ).to eq([
          "the dates and times you chose aren't available - choose new dates on https://www.gov.uk/prison-visits"
        ])
      end

      context 'when containing no_allowance' do
        let(:reasons) { [Rejection::NO_ALLOWANCE] }

        context 'with a date set' do
          before do
            rejection.assign_attributes(
              allowance_renews_on: allowance_renews_on
            )
          end

          it 'has the correct explanation' do
            expect(
              subject.email_formatted_reasons.map(&:explanation)
            ).to eq([
              "the prisoner has used their allowance of visits for this month - you can only book a visit from #{I18n.l(rejection.allowance_renews_on, format: :date_without_year)} onwards"
            ])
          end
        end

        context 'with no date' do
          it 'has the correct explanation' do
            expect(
              subject.email_formatted_reasons.map(&:explanation)
            ).to eq([
              "the prisoner has used their allowance of visits for this month"
            ])
          end
        end
      end

      context 'when containing not_on_list' do
        let(:reasons) { [Rejection::NOT_ON_THE_LIST] }

        it 'has the correct explanation' do
          expect(
            subject.email_formatted_reasons.map(&:explanation)
          ).to eq([
            "details for #{unlisted_visitor.anonymized_name} don't match our records or aren't on the prisoner's contact list - ask the prisoner to update their contact list with correct details, making sure that names appear exactly the same as on ID documents; if this is the prisoner's first visit (reception visit), then you need to contact the prison directly to book"
          ])
        end
      end

      context 'when containing visitor_other_reason' do
        let!(:other_rejection_visitor) do
          create(:visitor, visit: rejection.visit, other_rejection_reason: true)
        end

        let(:reasons) { [Rejection::VISITOR_OTHER_REASON] }

        it { expect(subject.email_formatted_reasons.map(&:explanation)).to be_empty }
      end

      context 'when containing banned' do
        let(:reasons) { [Rejection::BANNED] }

        it 'has the correct explanation' do
          expect(
            subject.email_formatted_reasons.map(&:explanation)
          ).to eq([
            "#{banned_visitor.anonymized_name} is banned from visiting the prison at the moment and should have received a letter from the prison."
          ])
        end
      end

      context 'when containing both a restriction and other rejection reason' do
        let(:reasons) do
          [
            Rejection::PRISONER_NON_ASSOCIATION,
            Rejection::OTHER_REJECTION_REASON
          ]
        end

        it "filters out the 'other' rejection reason" do
          expect(
            subject.email_formatted_reasons.map(&:explanation)
          ).to eq(["the prisoner has a restriction"])
        end
      end

      context 'when containing both child protection issues and no association' do
        let(:reasons) do
          [
            Rejection::CHILD_PROTECTION_ISSUES,
            Rejection::PRISONER_NON_ASSOCIATION
          ]
        end

        it 'only as the explanation once' do
          expect(
            subject.email_formatted_reasons.map(&:explanation)
          ).to eq(['the prisoner has a restriction'])
        end
      end

      context 'when containing both a no association and another non-restriction reason' do
        let(:reasons) do
          [
            Rejection::PRISONER_NON_ASSOCIATION,
            'prisoner_released'
          ]
        end

        it 'has a restricted and non restricted reasons' do
          expect(subject.email_formatted_reasons.map(&:explanation)).
            to contain_exactly('the prisoner has a restriction',
                               'the prisoner has been released - hopefully they will contact you soon')
        end
      end
    end
  end

  describe '#staff_formatted_reasons' do
    before do
      rejection.reasons = reasons
    end

    context 'when the prisoner has no VO' do
      let(:reasons) { [Rejection::NO_ALLOWANCE] }

      context 'with a date set' do
        before do
          rejection.assign_attributes(
            allowance_renews_on: allowance_renews_on
          )
        end

        it 'has the correct explanation' do
          expect(
            subject.staff_formatted_reasons
          ).to eq([
            "Prisoner has no visiting allowance. Allowance renews on #{I18n.l(rejection.allowance_renews_on, format: :date_without_year)}"
          ])
        end
      end

      context 'with no a date' do
        it 'has the correct explanation' do
          expect(
            subject.staff_formatted_reasons
          ).to eq(["Prisoner had no visiting allowance."])
        end
      end

      context 'when containing slot_unavailable' do
        let(:reasons) { [Rejection::SLOT_UNAVAILABLE] }

        it 'has the correct explanation' do
          expect(
            subject.staff_formatted_reasons
          ).to eq([
            "None of the dates and times chosen were available"
          ])
        end
      end
    end

    context 'when a visit is rejected for any other reason' do
      let(:reasons) { [Rejection::OTHER_REJECTION_REASON] }
      let(:detail) { "This visit cannot be booked" }

      before do
        rejection.assign_attributes(
          rejection_reason_detail: detail
        )
      end

      it 'has the correct explanation' do
        expect(
          subject.staff_formatted_reasons
        ).to eq(["Other: This visit cannot be booked"])
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

      context 'with an invalid date' do
        let(:allowance_renews_on) { { 1 => 1, 2 => 2, 3 => nil } }

        it 'retains the date pars' do
          expect(subject.allowance_renews_on).to have_attributes(year: 1, month: 2, day: nil)
        end
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
    let(:no_allowance)             { nil }
    let(:prisoner_out_of_prison)   { nil }
    let(:details_incorrect)        { nil }
    let(:prisoner_location_status) { nil }
    let(:nomis_checker) do
      double(StaffNomisChecker)
    end

    let(:prisoner_details_presenter) do
      instance_double(PrisonerDetailsPresenter)
    end

    let(:prisoner_location_presenter) do
      instance_double(PrisonerLocationPresenter, status: prisoner_location_status)
    end

    before do
      allow(subject).to receive(:nomis_checker).and_return(nomis_checker)
      allow(subject).to receive(:prisoner_details).and_return(prisoner_details_presenter)
      allow(subject).to receive(:prisoner_location).and_return(prisoner_location_presenter)
      allow(nomis_checker).to receive(:errors_for).
        with(anything) do
          if visit_bookable
            []
          else
            [anything]
          end
        end

      allow(prisoner_details_presenter).
        to receive(:details_incorrect?).
        and_return(details_incorrect)

      allow(nomis_checker).
        to receive(:no_allowance?).
        with(anything).
        and_return(no_allowance)

      allow(nomis_checker).
        to receive(:prisoner_out_of_prison?).
        with(anything).
        and_return(prisoner_out_of_prison)
    end

    shared_examples_for 'unchecked' do |checkbox_name|
      let(:checkbox) do
        Capybara.string subject.checkbox_for(checkbox_name)
      end

      it "#{checkbox_name} is not checked" do
        expect(checkbox).not_to have_css('[checked]')
      end
    end

    shared_examples_for 'checked' do |checkbox_name|
      let(:checkbox) do
        Capybara.string subject.checkbox_for(checkbox_name)
      end

      it "#{checkbox_name} is checked" do
        expect(checkbox).to have_css('[checked]')
      end
    end

    context 'with no unvisitable reasons and bookable slots' do
      let(:visit_bookable)         { true }
      let(:details_incorrect)      { false }
      let(:no_allowance)           { false }
      let(:prisoner_out_of_prison) { false }

      before do
        subject.apply_nomis_reasons
      end

      it_behaves_like 'unchecked', :prisoner_details_incorrect
      it_behaves_like 'unchecked', :no_allowance
      it_behaves_like 'unchecked', :prisoner_out_of_prison
    end

    context 'with no unvisitable reasons and unbookable slots' do
      let(:visit_bookable) { false }
      let(:details_incorrect) { false }
      let(:no_allowance) { false }
      let(:prisoner_out_of_prison) { false }

      before do
        subject.apply_nomis_reasons
      end

      it_behaves_like 'unchecked', :prisoner_details_incorrect
      it_behaves_like 'unchecked', :no_allowance
      it_behaves_like 'unchecked', :prisoner_out_of_prison
    end

    context 'when prisoner details incorrect and bookable slots' do
      let(:visit_bookable) { true }
      let(:details_incorrect) { true }

      before do
        subject.apply_nomis_reasons
      end

      it_behaves_like 'checked', :prisoner_details_incorrect
    end

    context 'when prisoner details incorrect and unbookable slots' do
      let(:visit_bookable) { false }
      let(:details_incorrect) { true }

      before do
        subject.apply_nomis_reasons
      end

      it_behaves_like 'checked', :prisoner_details_incorrect
    end

    context 'when prisoner location is invalid' do
      let(:visit_bookable)           { true }
      let(:details_incorrect)        { false }
      let(:prisoner_location_status) { PrisonerLocationValidation::INVALID }

      before do
        subject.apply_nomis_reasons
      end

      it_behaves_like 'checked', :prisoner_details_incorrect
    end

    context 'when prisoner location is unknown' do
      let(:visit_bookable)           { true }
      let(:details_incorrect)        { false }
      let(:prisoner_location_status) { PrisonerLocationValidation::UNKNOWN }

      before do
        subject.apply_nomis_reasons
      end

      it_behaves_like 'unchecked', :prisoner_details_incorrect
    end

    context 'with no allowance and bookable slots' do
      before do
        subject.apply_nomis_reasons
      end

      let(:visit_bookable) { true }
      let(:no_allowance) { true }

      it_behaves_like 'unchecked', :no_allowance
    end

    context 'with no allowance and unbookable slots' do
      before do
        subject.apply_nomis_reasons
      end

      let(:visit_bookable) { false }
      let(:no_allowance) { true }

      it_behaves_like 'checked', :no_allowance
    end

    context 'when prisoner out of prison and bookable slots' do
      before do
        subject.apply_nomis_reasons
      end

      let(:visit_bookable) { true }
      let(:prisoner_out_of_prison) { true }

      it_behaves_like 'unchecked', :prisoner_out_of_prison
    end

    context 'when prisoner out of prison and unbookable slots' do
      before do
        subject.apply_nomis_reasons
      end

      let(:visit_bookable) { false }
      let(:prisoner_out_of_prison) { true }

      it_behaves_like 'checked', :prisoner_out_of_prison
    end
  end
end
