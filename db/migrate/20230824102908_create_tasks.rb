class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :task_category, null: false
      t.boolean :completed, default: false, null: false
      t.timestamps
    end
  end
end
