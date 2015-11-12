class ReplaceAdditionalVisitorsWithTableThatUsesUuidPrimaryKey < ActiveRecord::Migration
  def change
    create_table :additional_visitors, id: :uuid do |t|
      t.uuid :visit_id, index: true, foreign_key: true, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false

      t.timestamps null: false
    end
  end
end
