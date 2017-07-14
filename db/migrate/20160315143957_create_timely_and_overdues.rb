class CreateTimelyAndOverdues < ActiveRecord::Migration[4.2]
  def change
    create_view :timely_and_overdues
  end
end
