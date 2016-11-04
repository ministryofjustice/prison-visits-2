module PrincipalVisitor
  extend ActiveSupport::Concern
  def principal_visitor
    visitors.first
  end

  def principal_visitor_id
    principal_visitor&.id
  end

  def principal_visitor_id=(visitor_id)
    vst_id = visitor_ids.detect { |v_id| v_id == visitor_id }
    if vst_id
      @principal_visitor = Visitor.find(vst_id)
    end
  end
end
