class StaffNomisCheckerFactory
  def self.for(visit)
    case visit.processing_state
    when 'requested'
      StaffNomisChecker.new(visit)
    else
      NullStaffNomisChecker.new
    end
  end
end
