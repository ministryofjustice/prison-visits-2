class MigrateReasonToReasons < ActiveRecord::Migration
  def change
    Rejection::REASONS.each do |reason|
      connection.execute "UPDATE rejections SET reasons = array_append(reasons, '#{reason}') WHERE reason = '#{reason}'"
    end
  end
end
