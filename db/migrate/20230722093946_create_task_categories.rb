class CreateTaskCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :task_categories do |t|
      t.references :task_group, null: false
      t.string :name, null: false, default: ''
      t.timestamps
    end
  end
end
