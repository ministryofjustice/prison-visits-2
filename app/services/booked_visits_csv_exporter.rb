require 'csv'

class BookedVisitsCsvExporter
  include DateHelper

  def initialize(data)
    @data = data
  end

  def to_csv
    visits = @data.values.flat_map(&:values).map(&:values).flatten

    CSV.generate(headers: headers, write_headers: true) do |csv|
      visits.each do |visit|
        csv << csv_row(visit)
      end
    end
  end

  def headers
    [
      'Status',
'Prison',
'Prisoner name',
'Prisoner number',
'Slot granted',
      'Closed visit',
'Lead visitor',
'Lead visitor dob',
      'Lead visitor allowed?',
'Phone number',
'Email address',
      'Visitor 2 name',
'Visitor 2 dob',
'Visitor 2 allowed?',
      'Visitor 3 name',
'Visitor 3 dob',
'Visitor 3 allowed?',
      'Visitor 4 name',
'Visitor 4 dob',
'Visitor 4 allowed?',
      'Visitor 5 name',
'Visitor 5 dob',
'Visitor 5 allowed?',
      'Visitor 6 name',
'Visitor 6 dob',
'Visitor 6 allowed?'
    ]
  end

private

  def csv_row(visit)
    visit_attrs(visit).merge(additional_visitor_attrs(visit.visitors))
  end

  def visit_attrs(visit)
    {
      'Status' => visit.processing_state,
      'Prison' => visit.prison_name,
      'Prisoner name' => visit.prisoner_full_name,
      'Prisoner number' => visit.prisoner_number,
      'Slot granted' => format_slot_for_staff(visit.slot_granted),
      'Closed visit' => visit.closed?,
      'Lead visitor' => visit.visitor_full_name,
      'Lead visitor dob' => visit.visitor_date_of_birth,
      'Lead visitor allowed?' => visit.principal_visitor.allowed?,
      'Phone number' => visit.contact_phone_no,
      'Email address' => visit.contact_email_address
    }
  end

  def additional_visitor_attrs(visitors)
    attrs = {}
    visitors[1..-1].each_with_index do |visitor, i|
      n = i + 2
      attrs["Visitor #{n} name"] = visitor.full_name
      attrs["Visitor #{n} dob"] = visitor.date_of_birth
      attrs["Visitor #{n} allowed?"] = visitor.allowed?
    end
    attrs
  end
end
