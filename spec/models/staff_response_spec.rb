require 'rails_helper'

RSpec.describe StaffResponse, type: :model do
  include_context 'with staff response setup'

  subject do
    described_class.new(
      visit: Visit.new(params),
      validate_visitors_nomis_ready: validate_visitors_nomis_ready)
  end

  describe 'multi_param dates' do
    let(:tomorrow)     { Date.current }
    let(:slot_granted) { nil }
    let(:multi_params_date) do
      {
        'allowance_renews_on(1i)' => tomorrow.year.to_s,
        'allowance_renews_on(2i)' => tomorrow.month.to_s,
        'allowance_renews_on(3i)' => tomorrow.day.to_s
      }
    end

    before do
      params[:rejection_attributes].merge!(multi_params_date)
    end

    context 'when a booking is not rejected for no allowance' do
      before do
        params[:rejection_attributes][:reasons] = [Rejection::SLOT_UNAVAILABLE]
      end

      it 'clears the allowance field' do
        expect(subject).to be_valid
        expect(subject.visit.rejection.allowance_renews_on).to eq(nil)
      end
    end

    context 'when a booking is rejected for no available allowance' do
      before do
        params[:rejection_attributes][:reasons] = [Rejection::NO_ALLOWANCE]
      end

      context 'when a valid renewal date' do
        it 'converts to a date' do
          expect(subject).to be_valid
          expect(subject.visit.rejection.allowance_renews_on).to eq(tomorrow)
        end
      end

      context 'when no date was set' do
        let(:multi_params_date) do
          {
            'allowance_renews_on(1i)' => '',
            'allowance_renews_on(2i)' => '',
            'allowance_renews_on(3i)' => ''
          }
        end

        it 'clears the date' do
          expect(subject).to be_valid
          expect(subject.visit.rejection.allowance_renews_on).to eq(nil)
        end
      end
    end
  end

  describe 'validating a staff response' do
    context 'when processable' do
      it { is_expected.to be_valid }
    end

    context 'when not processable' do
      let(:processing_state) { 'rejected' }

      before { expect(subject).not_to be_valid }

      specify { expect(subject.errors.full_messages).to eq(["Visit can't be processed"]) }
    end

    context 'when a rejection reasons and a slot is selected' do
      before do
        params[:rejection_attributes]['reasons'] = ['prisoner_moved']
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors.full_messages).
          to eq([
                  I18n.t('must_reject_or_accept_visit',
                         scope: %i[staff_response errors])
                ])
      end
    end

    context 'when visitors need to be ready for nomis' do
      let(:validate_visitors_nomis_ready) { 'true' }

      context 'with a rejected visit' do
        before do
          params[:rejection_attributes][:reasons] = [Rejection::NO_ALLOWANCE]
          params['slot_granted'] = ''
        end

        it 'does not require to process the visitors' do
          expect(subject).to be_valid
        end
      end

      context 'when a visitor is on the list and not have a nomis id' do
        before do
          params[:visitors_attributes]['0'][:nomis_id] = nil
          params[:visitors_attributes]['0'][:not_on_list] = nil
        end

        it 'is invalid' do
          expect(subject).to be_invalid

          expect(subject.errors.full_messages).
            to include(
              I18n.t('visitors_invalid',
                     scope: %i[activemodel errors models staff_response attributes base])
               )

          expect(subject.visit.visitors.first.errors[:base]).
            to include("Process this visitor to continue")
        end
      end

      context 'when a visitor is on the list and has a nomis id' do
        before do
          params[:visitors_attributes]['0'][:nomis_id] = 12_345
          params[:visitors_attributes]['0'][:not_on_list] = nil
        end

        it 'is valid' do
          expect(subject).to be_valid

          expect(subject.visit.visitors.first.errors).to be_empty
        end
      end
    end

    context 'with slot availability' do
      before do
        subject.valid?
      end

      context 'when a slot is available' do
        it { is_expected.to be_valid }
      end

      context 'when a slot is not available' do
        let(:slot_granted) { Rejection::SLOT_UNAVAILABLE }

        it { is_expected.to be_valid }

        it 'is has a rejection for slot unavailable' do
          expect(subject.visit.rejection.reasons).to eq([Rejection::SLOT_UNAVAILABLE])
        end
      end
    end

    context 'when the lead visitor is not on the list' do
      before do
        params[:visitors_attributes]['0']['not_on_list'] = true
        params[:visitors_attributes]['1'] = other_visitor.attributes.slice('id', 'banned', 'not_on_list')
      end

      let(:other_visitor) { build(:visitor, visit: visit) }

      it 'is rejected for not having lead visitor on the list' do
        expect(subject).to be_valid
        expect(subject.visit.rejection.reasons).to include(Rejection::NOT_ON_THE_LIST)
      end
    end

    context "when the lead visitor can't go for other reasons" do
      before do
        params[:visitors_attributes]['0']['other_rejection_reason'] = true
        params[:visitors_attributes]['1'] = other_visitor.attributes.slice('id', 'banned', 'not_on_list')
      end

      let(:other_visitor) { build(:visitor, visit: visit) }

      it 'is rejected for not having lead visitor on the list' do
        expect(subject).to be_valid
        expect(subject.visit.rejection.reasons).to contain_exactly(Rejection::VISITOR_OTHER_REASON)
      end
    end

    context 'when no slot granted' do
      let(:slot_granted) { '' }

      context 'when all visitors are unlisted' do
        let!(:unlisted_visitor) { create(:visitor, visit: visit) }

        before do
          unlisted_visitor.not_on_list = true
          params[:visitors_attributes]['1'] = unlisted_visitor.attributes.slice(*visitor_fields)
          params[:visitors_attributes]['0'][:not_on_list] = true
          subject.valid?
        end

        it { is_expected.to be_valid }

        it 'is has a rejection for visitor not on the list' do
          expect(subject.visit.rejection.reasons).to eq([Rejection::NOT_ON_THE_LIST])
        end
      end

      context 'when all visitor are banned' do
        let!(:unlisted_visitor) { create(:visitor, visit: visit) }
        let(:slot_granted)      { '' }

        before do
          unlisted_visitor.banned = true
          params[:visitors_attributes]['1'] = unlisted_visitor.attributes.slice(*visitor_fields)
          params[:visitors_attributes]['0'][:banned] = true
          subject.valid?
        end

        it { is_expected.to be_valid }

        it 'has a rejection for visitor banned' do
          expect(subject.visit.rejection.reasons).to eq([Rejection::BANNED])
        end
      end
    end
  end

  describe '#email_attrs' do
    let(:expected_params) do
      {
        'id' => nil,
        'prison_id' => visit.prison.id,
        'contact_email_address' => nil,
        'contact_phone_no' => nil,
        'processing_state' => 'requested',
        'reference_no' => 'A1234BC',
        'closed' => params[:closed],
        'prisoner_id' => visit.prisoner_id,
        'locale' => nil,
        'nomis_comments' => nil,
        'principal_visitor_id' => principal_visitor.id,
        'slot_option_0' => visit.slot_option_0,
        'slot_option_1' => visit.slot_option_1,
        'slot_option_2' => visit.slot_option_2,
        'slot_granted' => visit.slot_option_0,
        'visitors_attributes' => visit.visitors.each_with_object({}).with_index do |(visitor, h), i|
          h[i.to_s] = visitor.slice(*visitor_fields)
          h[i.to_s]['banned_until'] = visitor.banned_until.to_s
          h
        end
      }
    end

    context 'with no rejection' do
      before do
        subject.valid?
      end

      it 'has all the required serialized attributes' do
        expect(subject.email_attrs).to eq(expected_params)
      end
    end

    describe 'when rejected' do
      let(:slot_granted)                     { '' }
      let(:allowance_renew_date)             { 2.weeks.from_now.to_date }
      let(:multi_params_date) do
        {
          'allowance_renews_on(1i)' => allowance_renew_date.year.to_s,
          'allowance_renews_on(2i)' => allowance_renew_date.month.to_s,
          'allowance_renews_on(3i)' => allowance_renew_date.day.to_s
        }
      end

      before do
        params[:rejection_attributes][:reasons] = [Rejection::NO_ALLOWANCE]
        params[:rejection_attributes].merge!(multi_params_date)

        expected_params['rejection_attributes'] = {
          'id' => nil,
          'visit_id' => nil,
          'reasons' => [Rejection::NO_ALLOWANCE],
          'allowance_renews_on' => allowance_renew_date.to_s
        }
        expected_params['slot_granted'] = ''
        expect(subject).to be_valid
      end

      it 'has all the required attributes' do
        expect(subject.email_attrs).to eq(expected_params)
      end
    end
  end
end
