class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.date :start_date, null: false
      t.date :end_date
      t.string :status, null: false, default: "scheduled"

      t.timestamps
    end
    add_index :events, :start_date
  end
end
