class PercentilesByCalendarDate < ActiveRecord::Base
  include PercentileSerialisation

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false)
  end
end
