module Api
  class VisitsController < ApiController
    # When this app not longer handles all the booking steps it will probably be
    # worth refactoring this code. However, to minimize code divergence between
    # the apps until that point, for now this method simply populates each
    # processor step and uses the BookingRequestCreator to create the visit.
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def create
      prison = Prison.find_by!(id: params.fetch(:prison_id))

      prisoner_step = PrisonerStep.new(params.fetch(:prisoner))
      prisoner_step.prison_id = prison.id

      visitors = params.fetch(:visitors).map { |v|
        VisitorsStep::Visitor.new(v)
      }
      visitors_step = VisitorsStep.new(
        email_address: params.fetch(:contact_email_address),
        phone_no: params.fetch(:contact_phone_no),
        visitors: visitors,
        prison: prison
      )

      slots = params.fetch(:slot_options)
      slots_step = SlotsStep.new(
        option_0: slots.fetch(0), # We expect at least 1 slot
        option_1: slots.fetch(1, nil),
        option_2: slots.fetch(2, nil),
        prison: prison
      )

      locale = params.fetch(:locale)

      @visit = BookingRequestCreator.new.create!(
        prisoner_step, visitors_step, slots_step, locale
      )
    end
  end
end
