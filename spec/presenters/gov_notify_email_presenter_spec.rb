require "rails_helper"

RSpec.describe GovNotifyEmailerPresenter do
  subject { described_class.new }

  describe "formatting the email content" do
    describe "#one_off_message_text" do
      context "when the message is nil" do
        let(:message) { nil }

        it "retuns the empty string" do
          expect(subject.one_off_message_text(message)).to eq('')
        end
      end

      context "when a message is provided" do
        let(:message) { Message.new(user_id: '112', body: 'This is a test message') }

        it "formats the message" do
          expect(subject.one_off_message_text(message)).to eq('This is a test message')
        end
      end
    end

    describe "#cancellation_reasons" do
      let!(:cancelled_visit) { create(:cancelled_visit) }
      let(:cancellation) { create(:cancellation, visit: cancelled_visit) }

      context "when the cancellation is nil" do
        let(:cancellation) { nil }

        it "retuns the empty string" do
          expect(subject.cancellation_reasons(cancellation)).to eq('')
        end
      end

      context "when there is one cancellation reason" do
        it "retuns the cancellation reason" do
          cancellation.reasons = [Cancellation::CHILD_PROTECTION_ISSUES]
          decorated_visit = CancellationDecorator.decorate(cancellation)

          expect(subject.cancellation_reasons(decorated_visit)).to eq('there are restrictions around this prisoner. You may be able to visit them at a later date.')
        end
      end

      context "when there are mutiple cancellation reasons" do
        it "retuns the cancellation reasons" do
          cancellation.reasons = [Cancellation::CHILD_PROTECTION_ISSUES, Cancellation::VISITOR_BANNED]
          decorated_visit = CancellationDecorator.decorate(cancellation)

          expect(subject.cancellation_reasons(decorated_visit)).to eq(["there are restrictions around this prisoner. You may be able to visit them at a later date.", "you have been banned from visiting this prison. We’ve sent you a letter with further details."])
        end
      end
    end

    describe "#booked_subject_date" do
      context "when the visit.slot_granted is nil" do
        let(:visit) { create(:visit) }

        it "retuns the empty string" do
          expect(subject.booked_subject_date(visit)).to eq('')
        end
      end

      context "when the visit.slot_granted is present" do
        let(:booked_visit) { create(:booked_visit) }

        it "retuns the formatted slot_granted date" do
          expect(subject.booked_subject_date(booked_visit)).to eq('Monday 23 May 2:00pm for 2 hrs 10 mins')
        end
      end
    end

    describe "#what_not_to_bring_text" do
      context "when Medway Secure Training Centre is the chosen prison" do
        let(:prison) { create(:prison, name: 'Medway Secure Training Centre') }
        let(:booked_visit) { create(:booked_visit, prison: prison) }

        it "returns Medway Secure Training Centre specific text" do
          expect(subject.what_not_to_bring_text(booked_visit)).to include("Please don't bring anything restricted or illegal to the prison. For more information about what you can't bring call the prison on ")
        end
      end

      context "when it is any other chosen prison" do
        let(:prison) { create(:prison, name: 'A Random Prison') }
        let(:booked_visit) { create(:booked_visit, prison: prison) }

        it "returns the generic text" do
          expect(subject.what_not_to_bring_text(booked_visit)).to include("Please don't bring anything restricted or illegal to the prison. The prison page has more information about what you can bring")
        end
      end
    end
  end
end
