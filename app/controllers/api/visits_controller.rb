require 'human_readable_id'

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
      prison = Prison.find_by!(id: params.to_unsafe_h.fetch(:prison_id))

      prisoner_step = PrisonerStep.new(params.to_unsafe_h.fetch(:prisoner))
      prisoner_step.prison_id = prison.id

      visitors = params.to_unsafe_h.fetch(:visitors).map { |v|
        VisitorsStep::Visitor.new(v)
      }
      visitors_step = VisitorsStep.new(
        email_address: params.fetch(:contact_email_address),
        phone_no: params.fetch(:contact_phone_no),
        visitors: visitors,
        prison: prison
      )

      slots = params.to_unsafe_h.fetch(:slot_options)
      unless slots.is_a?(Array) && slots.size >= 1
        fail ParameterError, 'slot_options must contain >= slot'
      end
      slots_step = SlotsStep.new(
        option_0: slots.fetch(0), # We expect at least 1 slot
        option_1: slots.fetch(1, nil),
        option_2: slots.fetch(2, nil),
        prison: prison
      )

      # This is admitedly not great, but it will do until we remove the steps
      # from the app, at which point it will make make sense to implement
      # validation on this API call properly
      fail_if_invalid('prisoner', prisoner_step)
      fail_if_invalid('visitors', visitors_step)
      fail_if_invalid('slot_options', slots_step)

      @visit = BookingRequestCreator.new.create!(
        prisoner_step, visitors_step, slots_step, I18n.locale
      )

      render :show
    end

    def show
      @visit = visit
    end

    def destroy
      if visitor_cancellation_response.visitor_can_cancel?
        visitor_cancellation_response.cancel!
      elsif visitor_withdrawal_response.visitor_can_withdraw?
        visitor_withdrawal_response.withdraw!
      end

      @visit = visit
      render :show
    end

  private

    def visitor_cancellation_response
      @_visitor_cancellation_response ||=
        VisitorCancellationResponse.new(visit: visit)
    end

    def visitor_withdrawal_response
      @_visitor_withdrawal_response ||=
        VisitorWithdrawalResponse.new(visit: visit)
    end

    def visit
      # TODO: Delete the PK (id) lookup after people stop clicking on emails
      # using the guids ids.
      @_visit ||= begin
                    if HumanReadableId.human_readable?(params[:id])
                      Visit.find_by!(human_id: params[:id])
                    else
                      Visit.find(params[:id])
                    end
                  end
    end

    def fail_if_invalid(param, step)
      unless step.valid?
        fail ParameterError,
          "#{param} (#{step.errors.full_messages.join(', ')})"
      end
    end
  end
end
