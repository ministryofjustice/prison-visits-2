require 'rails_helper'
require 'maybe_date'

RSpec.describe StaffResponse, type: :model do
  include_context 'staff response setup'

  subject { described_class.new(visit: Visit.new(params)) }

  describe 'accessible dates' do
    let(:tomorrow)     { Date.current }
    let(:slot_granted) { nil }
    let(:accessible_date) do
      {
        'day'   => tomorrow.day,
        'month' => tomorrow.month,
        'year'  => tomorrow.year
      }
    end

    before do
      params[:rejection_attributes][:allowance_renews_on] = accessible_date
    end

    context 'given a booking is not rejected for no allowance' do
      before do
        params[:rejection_attributes][:reasons] = [Rejection::SLOT_UNAVAILABLE]
      end

      it 'clears the allowance field' do
        is_expected.to be_valid
        expect(subject.visit.rejection.allowance_renews_on).to eq(nil)
      end
    end

    context 'given a booking is rejected for no available allowance' do
      before do
        params[:rejection_attributes][:reasons] = [Rejection::NO_ALLOWANCE]
      end

      context 'given a valid renewal date' do
        it 'converts to a date' do
          is_expected.to be_valid
          expect(subject.visit.rejection.allowance_renews_on).to eq(tomorrow)
        end
      end

      context 'given not date was set' do
        let(:accessible_date) do
          { 'day' => '', 'month' => '', 'year' => '' }
        end

        it 'clears the date' do
          is_expected.to be_valid
          expect(subject.visit.rejection.allowance_renews_on).to eq(nil)
        end
      end

      context 'given an invalid date' do
        it 'does not convert to a date' do
          accessible_date['year'] = ''
          is_expected.to be_invalid
          expect(subject.visit.rejection.allowance_renews_on).to eq(accessible_date)
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

      before do
        is_expected.not_to be_valid
      end

      specify { expect(subject.errors.full_messages).to eq(["Visit can't be processed"]) }
    end

    context 'when a rejection reasons and a slot is selected' do
      before do
        params[:rejection_attributes]['reasons'] = ['prisoner_moved']
      end
      it 'is invalid' do
        is_expected.to be_invalid
        expect(subject.errors.full_messages).
          to eq([
            I18n.t('must_reject_or_accept_visit',
              scope: %i[staff_response errors])
          ])
      end
    end

    context 'slot availability' do
      before do subject.valid? end

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

    context 'no slot granted' do
      let(:slot_granted) { '' }

      context 'when all visitors are unlisted' do
        let!(:unlisted_visitor) { create(:visitor, visit: visit) }

        before do
          unlisted_visitor.not_on_list = true
          params[:visitors_attributes]['1'] = unlisted_visitor.attributes.slice('id', 'banned', 'not_on_list')
          params[:visitors_attributes]['0'][:not_on_list] = true
          subject.valid?
        end

        it { is_expected.to be_valid }

        it 'is has a rejection for visitor not on the list' do
          expect(subject.visit.rejection.reasons).to eq([Rejection::NOT_ON_THE_LIST, Rejection::NO_ADULT])
        end
      end

      context 'when all visitor are banned' do
        let!(:unlisted_visitor) { create(:visitor, visit: visit) }
        let(:slot_granted)      { '' }

        before do
          unlisted_visitor.banned = true
          params[:visitors_attributes]['1'] = unlisted_visitor.attributes.slice('id', 'banned', 'not_on_list')
          params[:visitors_attributes]['0'][:banned] = true
          subject.valid?
        end

        it { is_expected.to be_valid }

        it 'has a rejection for visitor banned' do
          expect(subject.visit.rejection.reasons).to eq([Rejection::BANNED, Rejection::NO_ADULT])
        end
      end
    end

    context 'without allowed adult visitors' do
      let!(:minor_visitor) { create(:visitor, date_of_birth: 17.years.ago, visit: visit) }

      before do
        params[:visitors_attributes]['0'][:banned] = true
        params[:visitors_attributes]['1'] = minor_visitor.attributes.slice('id', 'banned', 'not_on_list')
        subject.valid?
      end

      it 'has a rejection for no adult' do
        expect(subject.visit.rejection.reasons).to eq([Rejection::NO_ADULT])
      end
    end
  end

  describe '#email_attrs' do
    let(:expected_params) do
      {
        'id'                     => nil,
        'prison_id'              => visit.prison.id,
        'contact_email_address'  => nil,
        'contact_phone_no'       => nil,
        'processing_state'       => 'requested',
        'override_delivery_error' => false,
        'delivery_error_type'    => nil,
        'reference_no'           => 'A1234BC',
        'closed'                 => params[:closed],
        'prisoner_id'            => visit.prisoner_id,
        'locale'                 => nil,
        'slot_option_0'          => visit.slot_option_0,
        'slot_option_1'          => visit.slot_option_1,
        'slot_option_2'          => visit.slot_option_2,
        'slot_granted'           => visit.slot_option_0,
        'visitors_attributes'    => visit.visitors.each_with_object({}).with_index do |(visitor, h), i|
          h[i.to_s] = visitor.slice('id', 'not_on_list', 'banned')
          h[i.to_s]['banned_until'] = visitor.banned_until.to_s
          h
        end
      }
    end

    context 'with no rejection' do
      before do subject.valid?  end

      it 'has all the required serialized attributes' do
        expect(subject.email_attrs).to eq(expected_params)
      end
    end

    describe 'when rejected' do
      let(:slot_granted)                     { '' }
      let(:allowance_renew_date)             { 2.weeks.from_now.to_date }

      before do
        params[:rejection_attributes][:reasons] = [Rejection::NO_ALLOWANCE]
        params[:rejection_attributes][:allowance_renews_on] = {
          day:   allowance_renew_date.day,
          month: allowance_renew_date.month,
          year:  allowance_renew_date.year
        }

        expected_params['rejection_attributes'] = {
          'id'                              => nil,
          'visit_id'                        => nil,
          'reasons'                         => [Rejection::NO_ALLOWANCE],
          'allowance_renews_on'             => allowance_renew_date.to_s
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
