class CreateTaskTimeUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :task_time_units do |t|
      t.references :task, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at
      t.timestamps
    end
  end
end
