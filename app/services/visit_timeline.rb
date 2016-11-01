class VisitTimeline
  class Event
    def initialize(state:, created_at:, last:, user:)
      @state = state
      @created_at = created_at
      @last = last
      @user = user
    end

    attr_reader :state, :created_at, :last

    def user_name
      if @user.is_a?(Visitor)
        @user.full_name
      elsif @user.is_a?(User)
        @user.email
      end
    end
  end

  def initialize(visit)
    @visit = visit
  end

  def events
    events = @visit.visit_state_changes.reverse.map.with_index { |state, i|
      build_event_from_state_change(state, last: i.zero?)
    }

    events << build_requested_event(last: events.empty?)
    events.reverse
  end

private

  def build_requested_event(last:)
    Event.new(
      state: 'requested',
      created_at: @visit.created_at,
      last: last,
      user: @visit.principal_visitor
    )
  end

  def build_event_from_state_change(state, last:)
    user = if state.visit_state == 'withdrawn'
             @visit.principal_visitor
           else
             state.processed_by
           end

    Event.new(
      state:      state.visit_state,
      created_at: state.created_at,
      last:       last,
      user:       user)
  end
end
