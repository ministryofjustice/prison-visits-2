class CreateTimelyAndOverdues < ActiveRecord::Migration
  def change
    create_view :timely_and_overdues
  end
end
