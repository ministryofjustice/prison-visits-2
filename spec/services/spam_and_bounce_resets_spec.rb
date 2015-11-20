require 'rails_helper'

RSpec.describe SpamAndBounceResets do
  let(:visit) { build(:visit) }
  subject { described_class.new(visit) }

  describe '.perform_resets' do
    context 'when override_email_check is true' do
      before do
        visit.override_spam_or_bounce = true
      end

      context 'when reset.bounced? is true' do
        before do
          visit.spam_or_bounce = 'bounced'
        end

        it 'calls SendgridApi#remove_from_bounce_list' do
          expect_any_instance_of(SendgridApi).to receive(:remove_from_bounce_list)
          subject.perform_resets
        end
      end

      context 'when reset.bounced? is false' do
        before do
          visit.spam_or_bounce = nil
        end

        it 'does not call SendgridApi#remove_from_bounce_list' do
          expect_any_instance_of(SendgridApi).not_to receive(:remove_from_bounce_list)
          subject.perform_resets
        end
      end

      context 'when reset.spam_reported? is true' do
        before do
          visit.spam_or_bounce = 'spam_reported'
        end

        it 'calls SendgriApi#remove_from_spam_list' do
          expect_any_instance_of(SendgridApi).to receive(:remove_from_spam_list)
          subject.perform_resets
        end
      end

      context 'when reset.spam_reported? is false' do
        before do
          visit.spam_or_bounce = nil
        end

        it 'does not call SendgriApi#remove_from_spam_list' do
          expect_any_instance_of(SendgridApi).not_to receive(:remove_from_spam_list)
          subject.perform_resets
        end
      end
    end

    context 'when override_email_check is false' do
      before do
        visit.override_spam_or_bounce = false
      end

      context 'when reset.bounced? is true' do
        before do
          visit.spam_or_bounce = 'bounced'
        end

        it 'does not call SendgriApi#remove_from_bounce_list' do
          expect_any_instance_of(SendgridApi).not_to receive(:remove_from_bounce_list)
          subject.perform_resets
        end
      end

      context 'when reset.bounced? is false' do
        before do
          visit.spam_or_bounce = nil
        end

        it 'does not call SendgriApi#remove_from_bounce_list' do
          expect_any_instance_of(SendgridApi).not_to receive(:remove_from_bounce_list)
          subject.perform_resets
        end
      end
    end
  end
end
